import * as vscode from 'vscode';
import * as cp from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

export function activate(context: vscode.ExtensionContext) {
    console.log('EnviREAment extension is now active!');

    // Status bar item
    const statusBarItem = vscode.window.createStatusBarItem(
        vscode.StatusBarAlignment.Left,
        100
    );
    statusBarItem.text = '$(play) EnviREAment';
    statusBarItem.tooltip = 'EnviREAment Virtual REAPER Environment';
    statusBarItem.command = 'envireament.showStatus';
    statusBarItem.show();
    context.subscriptions.push(statusBarItem);

    // Output channel for EnviREAment
    const outputChannel = vscode.window.createOutputChannel('EnviREAment');
    context.subscriptions.push(outputChannel);

    // Command: Run Tests
    const runTestsCommand = vscode.commands.registerCommand(
        'envireament.runTests',
        async () => {
            const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
            if (!workspaceFolder) {
                vscode.window.showErrorMessage('No workspace folder found');
                return;
            }

            // Look for EnviREAment test runner in workspace or use system installation
            const testRunnerPath = findEnviREAmentTestRunner(
                workspaceFolder.uri.fsPath
            );

            if (!testRunnerPath) {
                const response = await vscode.window.showErrorMessage(
                    'EnviREAment test runner not found. Would you like to install it?',
                    'Install via pip',
                    'Install via npm',
                    'Cancel'
                );

                if (response === 'Install via pip') {
                    runCommand(
                        'pip install envireament',
                        workspaceFolder.uri.fsPath,
                        outputChannel
                    );
                } else if (response === 'Install via npm') {
                    runCommand(
                        'npm install envireament',
                        workspaceFolder.uri.fsPath,
                        outputChannel
                    );
                }
                return;
            }

            outputChannel.clear();
            outputChannel.show();

            const config = vscode.workspace.getConfiguration('envireament');
            const verbose = config.get<boolean>('verboseOutput', false);
            const luaPath = config.get<string>('luaPath', 'lua');

            const args = verbose ? ['--verbose'] : [];
            const command = `${luaPath} "${testRunnerPath}" ${args.join(' ')}`;

            outputChannel.appendLine(`Running EnviREAment tests: ${command}`);
            runCommand(command, workspaceFolder.uri.fsPath, outputChannel);
        }
    );

    // Command: Run Demo
    const runDemoCommand = vscode.commands.registerCommand(
        'envireament.runDemo',
        async () => {
            const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
            if (!workspaceFolder) {
                vscode.window.showErrorMessage('No workspace folder found');
                return;
            }

            const demoPath = findEnviREAmentDemo(workspaceFolder.uri.fsPath);

            if (!demoPath) {
                vscode.window.showErrorMessage('EnviREAment demo not found');
                return;
            }

            outputChannel.clear();
            outputChannel.show();

            const config = vscode.workspace.getConfiguration('envireament');
            const luaPath = config.get<string>('luaPath', 'lua');

            const command = `${luaPath} "${demoPath}"`;
            outputChannel.appendLine(`Running EnviREAment demo: ${command}`);
            runCommand(command, workspaceFolder.uri.fsPath, outputChannel);
        }
    );

    // Command: Show Status
    const showStatusCommand = vscode.commands.registerCommand(
        'envireament.showStatus',
        async () => {
            const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
            if (!workspaceFolder) {
                vscode.window.showInformationMessage(
                    'EnviREAment: No workspace folder'
                );
                return;
            }

            const hasEnviREAment =
                findEnviREAmentTestRunner(workspaceFolder.uri.fsPath) !== null;
            const luaFiles = await vscode.workspace.findFiles(
                '**/*.lua',
                null,
                10
            );

            const message = `EnviREAment Status:
• Virtual Environment: ${hasEnviREAment ? '✅ Available' : '❌ Not found'}
• Lua Files: ${luaFiles.length} found
• Workspace: ${workspaceFolder.name}`;

            vscode.window.showInformationMessage(message);
        }
    );

    // Command: Open Documentation
    const openDocsCommand = vscode.commands.registerCommand(
        'envireament.openDocs',
        () => {
            vscode.env.openExternal(
                vscode.Uri.parse(
                    'https://github.com/your-username/EnviREAment/docs'
                )
            );
        }
    );

    // Auto-run tests on save (if enabled)
    const onSaveHandler = vscode.workspace.onDidSaveTextDocument((document) => {
        const config = vscode.workspace.getConfiguration('envireament');
        const autoRun = config.get<boolean>('autoRunTests', false);

        if (autoRun && document.languageId === 'lua') {
            vscode.commands.executeCommand('envireament.runTests');
        }
    });

    // Register all commands and handlers
    context.subscriptions.push(
        runTestsCommand,
        runDemoCommand,
        showStatusCommand,
        openDocsCommand,
        onSaveHandler
    );

    // Show welcome message on first activation
    const isFirstTime = context.globalState.get('envireament.firstTime', true);
    if (isFirstTime) {
        vscode.window
            .showInformationMessage(
                'EnviREAment extension activated! Use the Command Palette (Cmd+Shift+P) to run EnviREAment commands.',
                'Run Tests',
                'View Docs'
            )
            .then((selection) => {
                if (selection === 'Run Tests') {
                    vscode.commands.executeCommand('envireament.runTests');
                } else if (selection === 'View Docs') {
                    vscode.commands.executeCommand('envireament.openDocs');
                }
            });
        context.globalState.update('envireament.firstTime', false);
    }
}

function findEnviREAmentTestRunner(workspacePath: string): string | null {
    // Look for test runner in workspace
    const localPath = path.join(workspacePath, 'enhanced_test_runner.lua');
    if (fs.existsSync(localPath)) {
        return localPath;
    }

    // Look for EnviREAment installation
    const nodeModulesPath = path.join(
        workspacePath,
        'node_modules',
        'envireament',
        'enhanced_test_runner.lua'
    );
    if (fs.existsSync(nodeModulesPath)) {
        return nodeModulesPath;
    }

    // Check if Python package is available
    try {
        const result = cp.execSync(
            'python3 -c "import envireament; print(envireament.get_virtual_reaper_path())"',
            { encoding: 'utf8', timeout: 5000 }
        );
        const virtualReaperPath = result.trim();
        const testRunnerPath = path.join(
            path.dirname(virtualReaperPath),
            'enhanced_test_runner.lua'
        );
        if (fs.existsSync(testRunnerPath)) {
            return testRunnerPath;
        }
    } catch (error) {
        // Python package not available
    }

    return null;
}

function findEnviREAmentDemo(workspacePath: string): string | null {
    // Look for demo in workspace
    const localPath = path.join(workspacePath, 'examples', 'main.lua');
    if (fs.existsSync(localPath)) {
        return localPath;
    }

    // Look for EnviREAment installation
    const nodeModulesPath = path.join(
        workspacePath,
        'node_modules',
        'envireament',
        'examples',
        'main.lua'
    );
    if (fs.existsSync(nodeModulesPath)) {
        return nodeModulesPath;
    }

    // Check if Python package is available
    try {
        const result = cp.execSync(
            'python3 -c "import envireament; print(envireament.get_examples_dir())"',
            { encoding: 'utf8', timeout: 5000 }
        );
        const examplesDir = result.trim();
        const demoPath = path.join(examplesDir, 'main.lua');
        if (fs.existsSync(demoPath)) {
            return demoPath;
        }
    } catch (error) {
        // Python package not available
    }

    return null;
}

function runCommand(
    command: string,
    cwd: string,
    outputChannel: vscode.OutputChannel
) {
    const process = cp.spawn(command, [], {
        shell: true,
        cwd: cwd,
        stdio: ['pipe', 'pipe', 'pipe'],
    });

    process.stdout?.on('data', (data) => {
        outputChannel.append(data.toString());
    });

    process.stderr?.on('data', (data) => {
        outputChannel.append(`ERROR: ${data.toString()}`);
    });

    process.on('close', (code) => {
        if (code === 0) {
            outputChannel.appendLine('\n✅ Command completed successfully');
            vscode.window.showInformationMessage(
                'EnviREAment command completed successfully'
            );
        } else {
            outputChannel.appendLine(
                `\n❌ Command failed with exit code ${code}`
            );
            vscode.window.showErrorMessage(
                `EnviREAment command failed with exit code ${code}`
            );
        }
    });

    process.on('error', (error) => {
        outputChannel.appendLine(`\n❌ Command error: ${error.message}`);
        vscode.window.showErrorMessage(
            `EnviREAment command error: ${error.message}`
        );
    });
}

export function deactivate() {
    console.log('EnviREAment extension deactivated');
}
