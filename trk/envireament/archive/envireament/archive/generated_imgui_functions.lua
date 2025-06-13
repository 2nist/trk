-- Generated ImGui Functions
-- Auto-generated virtual implementations for missing ImGui functions
-- Generated: 2025-05-30 17:23:13

local generated_functions = {
    ImGui_AcceptDragDropPayload = function(ctx, label, value, ...)
      log_api_call("ImGui_AcceptDragDropPayload", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_AcceptDragDropPayloadFiles = function(ctx, label, value, ...)
      log_api_call("ImGui_AcceptDragDropPayloadFiles", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_AcceptDragDropPayloadRGB = function(ctx, label, value, ...)
      log_api_call("ImGui_AcceptDragDropPayloadRGB", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_AcceptDragDropPayloadRGBA = function(ctx, label, value, ...)
      log_api_call("ImGui_AcceptDragDropPayloadRGBA", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_AlignTextToFramePadding = function(ctx, ...)
      log_api_call("ImGui_AlignTextToFramePadding", ctx, ...)
      return true
    end,

    ImGui_ArrowButton = function(ctx, ...)
      log_api_call("ImGui_ArrowButton", ctx, ...)
      return true
    end,

    ImGui_Attach = function(ctx, ...)
      log_api_call("ImGui_Attach", ctx, ...)
      return true
    end,

    ImGui_Begin = function(ctx, ...)
      log_api_call("ImGui_Begin", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginChild = function(ctx, ...)
      log_api_call("ImGui_BeginChild", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginCombo = function(ctx, ...)
      log_api_call("ImGui_BeginCombo", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginDisabled = function(ctx, ...)
      log_api_call("ImGui_BeginDisabled", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginDragDropSource = function(ctx, ...)
      log_api_call("ImGui_BeginDragDropSource", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginDragDropTarget = function(ctx, ...)
      log_api_call("ImGui_BeginDragDropTarget", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginGroup = function(ctx, ...)
      log_api_call("ImGui_BeginGroup", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginItemTooltip = function(ctx, ...)
      log_api_call("ImGui_BeginItemTooltip", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginListBox = function(ctx, ...)
      log_api_call("ImGui_BeginListBox", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginMainMenuBar = function(ctx, ...)
      log_api_call("ImGui_BeginMainMenuBar", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginMenu = function(ctx, ...)
      log_api_call("ImGui_BeginMenu", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginMenuBar = function(ctx, ...)
      log_api_call("ImGui_BeginMenuBar", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginPopup = function(ctx, ...)
      log_api_call("ImGui_BeginPopup", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginPopupContextItem = function(ctx, ...)
      log_api_call("ImGui_BeginPopupContextItem", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginPopupContextWindow = function(ctx, ...)
      log_api_call("ImGui_BeginPopupContextWindow", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginPopupModal = function(ctx, ...)
      log_api_call("ImGui_BeginPopupModal", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginTabBar = function(ctx, ...)
      log_api_call("ImGui_BeginTabBar", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginTabItem = function(ctx, ...)
      log_api_call("ImGui_BeginTabItem", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginTable = function(ctx, ...)
      log_api_call("ImGui_BeginTable", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_BeginTooltip = function(ctx, ...)
      log_api_call("ImGui_BeginTooltip", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_Bullet = function(ctx, ...)
      log_api_call("ImGui_Bullet", ctx, ...)
      return true
    end,

    ImGui_BulletText = function(ctx, ...)
      log_api_call("ImGui_BulletText", ctx, ...)
      return true
    end,

    ImGui_Button = function(ctx, ...)
      log_api_call("ImGui_Button", ctx, ...)
      return true
    end,

    ImGui_CalcItemWidth = function(ctx, ...)
      log_api_call("ImGui_CalcItemWidth", ctx, ...)
      return true
    end,

    ImGui_CalcTextSize = function(ctx, ...)
      log_api_call("ImGui_CalcTextSize", ctx, ...)
      return true
    end,

    ImGui_Checkbox = function(ctx, ...)
      log_api_call("ImGui_Checkbox", ctx, ...)
      return true
    end,

    ImGui_CheckboxFlags = function(ctx, ...)
      log_api_call("ImGui_CheckboxFlags", ctx, ...)
      return true
    end,

    ImGui_CloseCurrentPopup = function(ctx, ...)
      log_api_call("ImGui_CloseCurrentPopup", ctx, ...)
      return true
    end,

    ImGui_CollapsingHeader = function(ctx, ...)
      log_api_call("ImGui_CollapsingHeader", ctx, ...)
      return true
    end,

    ImGui_ColorButton = function(ctx, label, value, ...)
      log_api_call("ImGui_ColorButton", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_ColorConvertDouble4ToU32 = function(ctx, label, value, ...)
      log_api_call("ImGui_ColorConvertDouble4ToU32", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_ColorConvertHSVtoRGB = function(ctx, label, value, ...)
      log_api_call("ImGui_ColorConvertHSVtoRGB", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_ColorEdit3 = function(ctx, label, value, ...)
      log_api_call("ImGui_ColorEdit3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_ColorEdit4 = function(ctx, label, value, ...)
      log_api_call("ImGui_ColorEdit4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_ColorPicker3 = function(ctx, label, value, ...)
      log_api_call("ImGui_ColorPicker3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_ColorPicker4 = function(ctx, label, value, ...)
      log_api_call("ImGui_ColorPicker4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_Columns = function(ctx, ...)
      log_api_call("ImGui_Columns", ctx, ...)
      return true
    end,

    ImGui_Combo = function(ctx, ...)
      log_api_call("ImGui_Combo", ctx, ...)
      return true
    end,

    ImGui_CreateContext = function(ctx, ...)
      log_api_call("ImGui_CreateContext", ctx, ...)
      return true
    end,

    ImGui_CreateDrawListSplitter = function(ctx, ...)
      log_api_call("ImGui_CreateDrawListSplitter", ctx, ...)
      return false
    end,

    ImGui_CreateFunctionFromEEL = function(ctx, ...)
      log_api_call("ImGui_CreateFunctionFromEEL", ctx, ...)
      return true
    end,

    ImGui_CreateImageFromMem = function(ctx, ...)
      log_api_call("ImGui_CreateImageFromMem", ctx, ...)
      return true
    end,

    ImGui_CreateListClipper = function(ctx, ...)
      log_api_call("ImGui_CreateListClipper", ctx, ...)
      return false
    end,

    ImGui_CreateTextFilter = function(ctx, ...)
      log_api_call("ImGui_CreateTextFilter", ctx, ...)
      return true
    end,

    ImGui_DebugFlashStyleColor = function(ctx, label, value, ...)
      log_api_call("ImGui_DebugFlashStyleColor", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DebugStartItemPicker = function(ctx, ...)
      log_api_call("ImGui_DebugStartItemPicker", ctx, ...)
      return true
    end,

    ImGui_DragDouble = function(ctx, label, value, ...)
      log_api_call("ImGui_DragDouble", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragDouble2 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragDouble2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragDouble3 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragDouble3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragDouble4 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragDouble4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragDoubleN = function(ctx, label, value, ...)
      log_api_call("ImGui_DragDoubleN", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragFloat = function(ctx, label, value, ...)
      log_api_call("ImGui_DragFloat", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragFloatRange2 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragFloatRange2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragInt = function(ctx, label, value, ...)
      log_api_call("ImGui_DragInt", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragInt2 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragInt2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragInt3 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragInt3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragInt4 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragInt4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragIntRange2 = function(ctx, label, value, ...)
      log_api_call("ImGui_DragIntRange2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DragScalar = function(ctx, label, value, ...)
      log_api_call("ImGui_DragScalar", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DrawListSplitter_Merge = function(ctx, ...)
      log_api_call("ImGui_DrawListSplitter_Merge", ctx, ...)
      return false
    end,

    ImGui_DrawListSplitter_SetCurrentChannel = function(ctx, ...)
      log_api_call("ImGui_DrawListSplitter_SetCurrentChannel", ctx, ...)
      return false
    end,

    ImGui_DrawListSplitter_Split = function(ctx, ...)
      log_api_call("ImGui_DrawListSplitter_Split", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddBezierCubic = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddBezierCubic", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddBezierQuadratic = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddBezierQuadratic", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddCircle = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddCircle", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddCircleFilled = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddCircleFilled", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddEllipse = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddEllipse", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddEllipseFilled = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddEllipseFilled", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddImage = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddImage", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddLine = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddLine", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddNgon = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddNgon", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddNgonFilled = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddNgonFilled", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddPolyline = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddPolyline", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddRect = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddRect", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddRectFilled = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddRectFilled", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddRectFilledMultiColor = function(ctx, label, value, ...)
      log_api_call("ImGui_DrawList_AddRectFilledMultiColor", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_DrawList_AddText = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddText", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddTextEx = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddTextEx", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddTriangle = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddTriangle", ctx, ...)
      return false
    end,

    ImGui_DrawList_AddTriangleFilled = function(ctx, ...)
      log_api_call("ImGui_DrawList_AddTriangleFilled", ctx, ...)
      return false
    end,

    ImGui_DrawList_PathArcTo = function(ctx, ...)
      log_api_call("ImGui_DrawList_PathArcTo", ctx, ...)
      return false
    end,

    ImGui_DrawList_PathBezierQuadraticCurveTo = function(ctx, ...)
      log_api_call("ImGui_DrawList_PathBezierQuadraticCurveTo", ctx, ...)
      return false
    end,

    ImGui_DrawList_PathFillConcave = function(ctx, ...)
      log_api_call("ImGui_DrawList_PathFillConcave", ctx, ...)
      return false
    end,

    ImGui_DrawList_PathFillConvex = function(ctx, ...)
      log_api_call("ImGui_DrawList_PathFillConvex", ctx, ...)
      return false
    end,

    ImGui_DrawList_PathLineTo = function(ctx, ...)
      log_api_call("ImGui_DrawList_PathLineTo", ctx, ...)
      return false
    end,

    ImGui_DrawList_PathStroke = function(ctx, ...)
      log_api_call("ImGui_DrawList_PathStroke", ctx, ...)
      return false
    end,

    ImGui_DrawList_PopClipRect = function(ctx, ...)
      log_api_call("ImGui_DrawList_PopClipRect", ctx, ...)
      return false
    end,

    ImGui_DrawList_PushClipRect = function(ctx, ...)
      log_api_call("ImGui_DrawList_PushClipRect", ctx, ...)
      return false
    end,

    ImGui_Dummy = function(ctx, ...)
      log_api_call("ImGui_Dummy", ctx, ...)
      return true
    end,

    ImGui_End = function(ctx, ...)
      log_api_call("ImGui_End", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndChild = function(ctx, ...)
      log_api_call("ImGui_EndChild", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndCombo = function(ctx, ...)
      log_api_call("ImGui_EndCombo", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndDisabled = function(ctx, ...)
      log_api_call("ImGui_EndDisabled", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndDragDropSource = function(ctx, ...)
      log_api_call("ImGui_EndDragDropSource", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndDragDropTarget = function(ctx, ...)
      log_api_call("ImGui_EndDragDropTarget", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndGroup = function(ctx, ...)
      log_api_call("ImGui_EndGroup", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndListBox = function(ctx, ...)
      log_api_call("ImGui_EndListBox", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndMainMenuBar = function(ctx, ...)
      log_api_call("ImGui_EndMainMenuBar", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndMenu = function(ctx, ...)
      log_api_call("ImGui_EndMenu", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndMenuBar = function(ctx, ...)
      log_api_call("ImGui_EndMenuBar", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndPopup = function(ctx, ...)
      log_api_call("ImGui_EndPopup", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndTabBar = function(ctx, ...)
      log_api_call("ImGui_EndTabBar", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndTabItem = function(ctx, ...)
      log_api_call("ImGui_EndTabItem", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndTable = function(ctx, ...)
      log_api_call("ImGui_EndTable", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_EndTooltip = function(ctx, ...)
      log_api_call("ImGui_EndTooltip", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_Function_GetValue = function(ctx, ...)
      log_api_call("ImGui_Function_GetValue", ctx, ...)
      return false
    end,

    ImGui_Function_GetValue_String = function(ctx, ...)
      log_api_call("ImGui_Function_GetValue_String", ctx, ...)
      return false
    end,

    ImGui_Function_SetValue = function(ctx, ...)
      log_api_call("ImGui_Function_SetValue", ctx, ...)
      return true
    end,

    ImGui_Function_SetValue_String = function(ctx, ...)
      log_api_call("ImGui_Function_SetValue_String", ctx, ...)
      return true
    end,

    ImGui_GetBackgroundDrawList = function(ctx, ...)
      log_api_call("ImGui_GetBackgroundDrawList", ctx, ...)
      return false
    end,

    ImGui_GetBuiltinPath = function(ctx, ...)
      log_api_call("ImGui_GetBuiltinPath", ctx, ...)
      return false
    end,

    ImGui_GetColor = function(ctx, label, value, ...)
      log_api_call("ImGui_GetColor", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_GetColorEx = function(ctx, label, value, ...)
      log_api_call("ImGui_GetColorEx", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_GetColorU32 = function(ctx, label, value, ...)
      log_api_call("ImGui_GetColorU32", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_GetColumnIndex = function(ctx, ...)
      log_api_call("ImGui_GetColumnIndex", ctx, ...)
      return false
    end,

    ImGui_GetColumnOffset = function(ctx, ...)
      log_api_call("ImGui_GetColumnOffset", ctx, ...)
      return false
    end,

    ImGui_GetColumnWidth = function(ctx, ...)
      log_api_call("ImGui_GetColumnWidth", ctx, ...)
      return false
    end,

    ImGui_GetConfigVar = function(ctx, ...)
      log_api_call("ImGui_GetConfigVar", ctx, ...)
      return false
    end,

    ImGui_GetContentRegionAvail = function(ctx, ...)
      log_api_call("ImGui_GetContentRegionAvail", ctx, ...)
      return false
    end,

    ImGui_GetCursorPos = function(ctx, ...)
      log_api_call("ImGui_GetCursorPos", ctx, ...)
      return false
    end,

    ImGui_GetCursorPosX = function(ctx, ...)
      log_api_call("ImGui_GetCursorPosX", ctx, ...)
      return false
    end,

    ImGui_GetCursorScreenPos = function(ctx, ...)
      log_api_call("ImGui_GetCursorScreenPos", ctx, ...)
      return false
    end,

    ImGui_GetCursorStartPos = function(ctx, ...)
      log_api_call("ImGui_GetCursorStartPos", ctx, ...)
      return false
    end,

    ImGui_GetDeltaTime = function(ctx, ...)
      log_api_call("ImGui_GetDeltaTime", ctx, ...)
      return false
    end,

    ImGui_GetDragDropPayloadFile = function(ctx, label, value, ...)
      log_api_call("ImGui_GetDragDropPayloadFile", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_GetFont = function(ctx, ...)
      log_api_call("ImGui_GetFont", ctx, ...)
      return false
    end,

    ImGui_GetFontSize = function(ctx, ...)
      log_api_call("ImGui_GetFontSize", ctx, ...)
      return false
    end,

    ImGui_GetForegroundDrawList = function(ctx, ...)
      log_api_call("ImGui_GetForegroundDrawList", ctx, ...)
      return false
    end,

    ImGui_GetFrameCount = function(ctx, ...)
      log_api_call("ImGui_GetFrameCount", ctx, ...)
      return false
    end,

    ImGui_GetFrameHeight = function(ctx, ...)
      log_api_call("ImGui_GetFrameHeight", ctx, ...)
      return false
    end,

    ImGui_GetFrameHeightWithSpacing = function(ctx, ...)
      log_api_call("ImGui_GetFrameHeightWithSpacing", ctx, ...)
      return false
    end,

    ImGui_GetIO = function(ctx, ...)
      log_api_call("ImGui_GetIO", ctx, ...)
      return false
    end,

    ImGui_GetInputQueueCharacter = function(ctx, label, value, ...)
      log_api_call("ImGui_GetInputQueueCharacter", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_GetItemID = function(ctx, ...)
      log_api_call("ImGui_GetItemID", ctx, ...)
      return false
    end,

    ImGui_GetItemRectMax = function(ctx, ...)
      log_api_call("ImGui_GetItemRectMax", ctx, ...)
      return false
    end,

    ImGui_GetItemRectMin = function(ctx, ...)
      log_api_call("ImGui_GetItemRectMin", ctx, ...)
      return false
    end,

    ImGui_GetItemRectSize = function(ctx, ...)
      log_api_call("ImGui_GetItemRectSize", ctx, ...)
      return false
    end,

    ImGui_GetKeyDownDuration = function(ctx, ...)
      log_api_call("ImGui_GetKeyDownDuration", ctx, ...)
      return false
    end,

    ImGui_GetMainViewport = function(ctx, ...)
      log_api_call("ImGui_GetMainViewport", ctx, ...)
      return false
    end,

    ImGui_GetMouseClickedPos = function(ctx, ...)
      log_api_call("ImGui_GetMouseClickedPos", ctx, ...)
      return false
    end,

    ImGui_GetMouseCursor = function(ctx, ...)
      log_api_call("ImGui_GetMouseCursor", ctx, ...)
      return false
    end,

    ImGui_GetMouseDelta = function(ctx, ...)
      log_api_call("ImGui_GetMouseDelta", ctx, ...)
      return false
    end,

    ImGui_GetMouseDownDuration = function(ctx, ...)
      log_api_call("ImGui_GetMouseDownDuration", ctx, ...)
      return false
    end,

    ImGui_GetMouseDragDelta = function(ctx, label, value, ...)
      log_api_call("ImGui_GetMouseDragDelta", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_GetMousePos = function(ctx, ...)
      log_api_call("ImGui_GetMousePos", ctx, ...)
      return false
    end,

    ImGui_GetMouseWheel = function(ctx, ...)
      log_api_call("ImGui_GetMouseWheel", ctx, ...)
      return false
    end,

    ImGui_GetScrollMaxX = function(ctx, ...)
      log_api_call("ImGui_GetScrollMaxX", ctx, ...)
      return false
    end,

    ImGui_GetScrollMaxY = function(ctx, ...)
      log_api_call("ImGui_GetScrollMaxY", ctx, ...)
      return false
    end,

    ImGui_GetScrollX = function(ctx, ...)
      log_api_call("ImGui_GetScrollX", ctx, ...)
      return false
    end,

    ImGui_GetScrollY = function(ctx, ...)
      log_api_call("ImGui_GetScrollY", ctx, ...)
      return false
    end,

    ImGui_GetStyleColor = function(ctx, label, value, ...)
      log_api_call("ImGui_GetStyleColor", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_GetStyleVar = function(ctx, ...)
      log_api_call("ImGui_GetStyleVar", ctx, ...)
      return false
    end,

    ImGui_GetTextLineHeight = function(ctx, ...)
      log_api_call("ImGui_GetTextLineHeight", ctx, ...)
      return false
    end,

    ImGui_GetTextLineHeightWithSpacing = function(ctx, ...)
      log_api_call("ImGui_GetTextLineHeightWithSpacing", ctx, ...)
      return false
    end,

    ImGui_GetTime = function(ctx, ...)
      log_api_call("ImGui_GetTime", ctx, ...)
      return false
    end,

    ImGui_GetTreeNodeToLabelSpacing = function(ctx, ...)
      log_api_call("ImGui_GetTreeNodeToLabelSpacing", ctx, ...)
      return false
    end,

    ImGui_GetVersion = function(ctx, ...)
      log_api_call("ImGui_GetVersion", ctx, ...)
      return false
    end,

    ImGui_GetWindowContentRegionMax = function(ctx, ...)
      log_api_call("ImGui_GetWindowContentRegionMax", ctx, ...)
      return false
    end,

    ImGui_GetWindowDockID = function(ctx, ...)
      log_api_call("ImGui_GetWindowDockID", ctx, ...)
      return false
    end,

    ImGui_GetWindowDrawList = function(ctx, ...)
      log_api_call("ImGui_GetWindowDrawList", ctx, ...)
      return false
    end,

    ImGui_GetWindowPos = function(ctx, ...)
      log_api_call("ImGui_GetWindowPos", ctx, ...)
      return false
    end,

    ImGui_GetWindowSize = function(ctx, ...)
      log_api_call("ImGui_GetWindowSize", ctx, ...)
      return false
    end,

    ImGui_GetWindowViewport = function(ctx, ...)
      log_api_call("ImGui_GetWindowViewport", ctx, ...)
      return false
    end,

    ImGui_GetWindowWidth = function(ctx, ...)
      log_api_call("ImGui_GetWindowWidth", ctx, ...)
      return false
    end,

    ImGui_Image = function(ctx, ...)
      log_api_call("ImGui_Image", ctx, ...)
      return true
    end,

    ImGui_ImageButton = function(ctx, ...)
      log_api_call("ImGui_ImageButton", ctx, ...)
      return true
    end,

    ImGui_Image_GetSize = function(ctx, ...)
      log_api_call("ImGui_Image_GetSize", ctx, ...)
      return false
    end,

    ImGui_Indent = function(ctx, ...)
      log_api_call("ImGui_Indent", ctx, ...)
      return true
    end,

    ImGui_InputDouble = function(ctx, label, value, ...)
      log_api_call("ImGui_InputDouble", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputDouble2 = function(ctx, label, value, ...)
      log_api_call("ImGui_InputDouble2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputDouble3 = function(ctx, label, value, ...)
      log_api_call("ImGui_InputDouble3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputDouble4 = function(ctx, label, value, ...)
      log_api_call("ImGui_InputDouble4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputDoubleN = function(ctx, label, value, ...)
      log_api_call("ImGui_InputDoubleN", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputFloat = function(ctx, label, value, ...)
      log_api_call("ImGui_InputFloat", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputInt = function(ctx, label, value, ...)
      log_api_call("ImGui_InputInt", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputInt2 = function(ctx, label, value, ...)
      log_api_call("ImGui_InputInt2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputInt3 = function(ctx, label, value, ...)
      log_api_call("ImGui_InputInt3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputInt4 = function(ctx, label, value, ...)
      log_api_call("ImGui_InputInt4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputScalar = function(ctx, label, value, ...)
      log_api_call("ImGui_InputScalar", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputText = function(ctx, label, value, ...)
      log_api_call("ImGui_InputText", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputTextMultiline = function(ctx, label, value, ...)
      log_api_call("ImGui_InputTextMultiline", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InputTextWithHint = function(ctx, label, value, ...)
      log_api_call("ImGui_InputTextWithHint", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_InvisibleButton = function(ctx, ...)
      log_api_call("ImGui_InvisibleButton", ctx, ...)
      return false
    end,

    ImGui_IsAnyItemHovered = function(ctx, ...)
      log_api_call("ImGui_IsAnyItemHovered", ctx, ...)
      return false
    end,

    ImGui_IsItemActivated = function(ctx, ...)
      log_api_call("ImGui_IsItemActivated", ctx, ...)
      return false
    end,

    ImGui_IsItemActive = function(ctx, ...)
      log_api_call("ImGui_IsItemActive", ctx, ...)
      return false
    end,

    ImGui_IsItemClicked = function(ctx, ...)
      log_api_call("ImGui_IsItemClicked", ctx, ...)
      return false
    end,

    ImGui_IsItemDeactivated = function(ctx, ...)
      log_api_call("ImGui_IsItemDeactivated", ctx, ...)
      return false
    end,

    ImGui_IsItemDeactivatedAfterEdit = function(ctx, ...)
      log_api_call("ImGui_IsItemDeactivatedAfterEdit", ctx, ...)
      return false
    end,

    ImGui_IsItemEdited = function(ctx, ...)
      log_api_call("ImGui_IsItemEdited", ctx, ...)
      return false
    end,

    ImGui_IsItemFocused = function(ctx, ...)
      log_api_call("ImGui_IsItemFocused", ctx, ...)
      return false
    end,

    ImGui_IsItemHovered = function(ctx, ...)
      log_api_call("ImGui_IsItemHovered", ctx, ...)
      return false
    end,

    ImGui_IsItemToggledOpen = function(ctx, ...)
      log_api_call("ImGui_IsItemToggledOpen", ctx, ...)
      return false
    end,

    ImGui_IsItemVisible = function(ctx, ...)
      log_api_call("ImGui_IsItemVisible", ctx, ...)
      return false
    end,

    ImGui_IsKeyDown = function(ctx, ...)
      log_api_call("ImGui_IsKeyDown", ctx, ...)
      return false
    end,

    ImGui_IsKeyPressed = function(ctx, ...)
      log_api_call("ImGui_IsKeyPressed", ctx, ...)
      return false
    end,

    ImGui_IsMouseClicked = function(ctx, ...)
      log_api_call("ImGui_IsMouseClicked", ctx, ...)
      return false
    end,

    ImGui_IsMouseDoubleClicked = function(ctx, ...)
      log_api_call("ImGui_IsMouseDoubleClicked", ctx, ...)
      return false
    end,

    ImGui_IsMouseDown = function(ctx, ...)
      log_api_call("ImGui_IsMouseDown", ctx, ...)
      return false
    end,

    ImGui_IsMouseDragging = function(ctx, label, value, ...)
      log_api_call("ImGui_IsMouseDragging", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_IsMousePosValid = function(ctx, ...)
      log_api_call("ImGui_IsMousePosValid", ctx, ...)
      return false
    end,

    ImGui_IsMouseReleased = function(ctx, ...)
      log_api_call("ImGui_IsMouseReleased", ctx, ...)
      return false
    end,

    ImGui_IsWindowDocked = function(ctx, ...)
      log_api_call("ImGui_IsWindowDocked", ctx, ...)
      return false
    end,

    ImGui_IsWindowFocused = function(ctx, ...)
      log_api_call("ImGui_IsWindowFocused", ctx, ...)
      return false
    end,

    ImGui_IsWindowHovered = function(ctx, ...)
      log_api_call("ImGui_IsWindowHovered", ctx, ...)
      return false
    end,

    ImGui_LabelText = function(ctx, ...)
      log_api_call("ImGui_LabelText", ctx, ...)
      return true
    end,

    ImGui_ListBox = function(ctx, ...)
      log_api_call("ImGui_ListBox", ctx, ...)
      return false
    end,

    ImGui_ListClipper_Begin = function(ctx, ...)
      log_api_call("ImGui_ListClipper_Begin", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_ListClipper_End = function(ctx, ...)
      log_api_call("ImGui_ListClipper_End", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,

    ImGui_ListClipper_GetDisplayRange = function(ctx, ...)
      log_api_call("ImGui_ListClipper_GetDisplayRange", ctx, ...)
      return false
    end,

    ImGui_ListClipper_Step = function(ctx, ...)
      log_api_call("ImGui_ListClipper_Step", ctx, ...)
      return false
    end,

    ImGui_LogFinish = function(ctx, ...)
      log_api_call("ImGui_LogFinish", ctx, ...)
      return false
    end,

    ImGui_LogText = function(ctx, ...)
      log_api_call("ImGui_LogText", ctx, ...)
      return true
    end,

    ImGui_LogToClipboard = function(ctx, ...)
      log_api_call("ImGui_LogToClipboard", ctx, ...)
      return true
    end,

    ImGui_LogToFile = function(ctx, ...)
      log_api_call("ImGui_LogToFile", ctx, ...)
      return true
    end,

    ImGui_LogToTTY = function(ctx, ...)
      log_api_call("ImGui_LogToTTY", ctx, ...)
      return true
    end,

    ImGui_MenuItem = function(ctx, ...)
      log_api_call("ImGui_MenuItem", ctx, ...)
      return true
    end,

    ImGui_NewLine = function(draw_list, ...)
      log_api_call("ImGui_NewLine", draw_list, ...)
      return true
    end,

    ImGui_NextColumn = function(ctx, ...)
      log_api_call("ImGui_NextColumn", ctx, ...)
      return true
    end,

    ImGui_NumericLimits_Double = function(ctx, ...)
      log_api_call("ImGui_NumericLimits_Double", ctx, ...)
      return true
    end,

    ImGui_NumericLimits_Float = function(ctx, ...)
      log_api_call("ImGui_NumericLimits_Float", ctx, ...)
      return true
    end,

    ImGui_OpenPopup = function(ctx, ...)
      log_api_call("ImGui_OpenPopup", ctx, ...)
      return true
    end,

    ImGui_OpenPopupOnItemClick = function(ctx, ...)
      log_api_call("ImGui_OpenPopupOnItemClick", ctx, ...)
      return true
    end,

    ImGui_PlotHistogram = function(ctx, ...)
      log_api_call("ImGui_PlotHistogram", ctx, ...)
      return false
    end,

    ImGui_PlotLines = function(draw_list, ...)
      log_api_call("ImGui_PlotLines", draw_list, ...)
      return true
    end,

    ImGui_PopButtonRepeat = function(ctx, ...)
      log_api_call("ImGui_PopButtonRepeat", ctx, ...)
      return true
    end,

    ImGui_PopClipRect = function(draw_list, ...)
      log_api_call("ImGui_PopClipRect", draw_list, ...)
      return true
    end,

    ImGui_PopID = function(ctx, ...)
      log_api_call("ImGui_PopID", ctx, ...)
      return true
    end,

    ImGui_PopItemWidth = function(ctx, ...)
      log_api_call("ImGui_PopItemWidth", ctx, ...)
      return true
    end,

    ImGui_PopStyleColor = function(ctx, label, value, ...)
      log_api_call("ImGui_PopStyleColor", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_PopStyleVar = function(ctx, ...)
      log_api_call("ImGui_PopStyleVar", ctx, ...)
      return true
    end,

    ImGui_PopTabStop = function(ctx, ...)
      log_api_call("ImGui_PopTabStop", ctx, ...)
      return true
    end,

    ImGui_PopTextWrapPos = function(ctx, ...)
      log_api_call("ImGui_PopTextWrapPos", ctx, ...)
      return true
    end,

    ImGui_ProgressBar = function(ctx, ...)
      log_api_call("ImGui_ProgressBar", ctx, ...)
      return true
    end,

    ImGui_PushButtonRepeat = function(ctx, ...)
      log_api_call("ImGui_PushButtonRepeat", ctx, ...)
      return true
    end,

    ImGui_PushClipRect = function(draw_list, ...)
      log_api_call("ImGui_PushClipRect", draw_list, ...)
      return true
    end,

    ImGui_PushID = function(ctx, ...)
      log_api_call("ImGui_PushID", ctx, ...)
      return true
    end,

    ImGui_PushItemWidth = function(ctx, ...)
      log_api_call("ImGui_PushItemWidth", ctx, ...)
      return true
    end,

    ImGui_PushStyleColor = function(ctx, label, value, ...)
      log_api_call("ImGui_PushStyleColor", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_PushStyleVar = function(ctx, ...)
      log_api_call("ImGui_PushStyleVar", ctx, ...)
      return true
    end,

    ImGui_PushTabStop = function(ctx, ...)
      log_api_call("ImGui_PushTabStop", ctx, ...)
      return true
    end,

    ImGui_PushTextWrapPos = function(ctx, ...)
      log_api_call("ImGui_PushTextWrapPos", ctx, ...)
      return true
    end,

    ImGui_RadioButton = function(ctx, ...)
      log_api_call("ImGui_RadioButton", ctx, ...)
      return true
    end,

    ImGui_RadioButtonEx = function(ctx, ...)
      log_api_call("ImGui_RadioButtonEx", ctx, ...)
      return true
    end,

    ImGui_ResetMouseDragDelta = function(ctx, label, value, ...)
      log_api_call("ImGui_ResetMouseDragDelta", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SameLine = function(draw_list, ...)
      log_api_call("ImGui_SameLine", draw_list, ...)
      return true
    end,

    ImGui_Selectable = function(ctx, ...)
      log_api_call("ImGui_Selectable", ctx, ...)
      return true
    end,

    ImGui_Separator = function(ctx, ...)
      log_api_call("ImGui_Separator", ctx, ...)
      return true
    end,

    ImGui_SeparatorText = function(ctx, ...)
      log_api_call("ImGui_SeparatorText", ctx, ...)
      return true
    end,

    ImGui_SetColorEditOptions = function(ctx, label, value, ...)
      log_api_call("ImGui_SetColorEditOptions", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SetConfigVar = function(ctx, ...)
      log_api_call("ImGui_SetConfigVar", ctx, ...)
      return true
    end,

    ImGui_SetCursorPosX = function(ctx, ...)
      log_api_call("ImGui_SetCursorPosX", ctx, ...)
      return true
    end,

    ImGui_SetCursorScreenPos = function(ctx, ...)
      log_api_call("ImGui_SetCursorScreenPos", ctx, ...)
      return true
    end,

    ImGui_SetDragDropPayload = function(ctx, label, value, ...)
      log_api_call("ImGui_SetDragDropPayload", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SetItemDefaultFocus = function(ctx, ...)
      log_api_call("ImGui_SetItemDefaultFocus", ctx, ...)
      return true
    end,

    ImGui_SetItemTooltip = function(ctx, ...)
      log_api_call("ImGui_SetItemTooltip", ctx, ...)
      return true
    end,

    ImGui_SetKeyboardFocusHere = function(ctx, ...)
      log_api_call("ImGui_SetKeyboardFocusHere", ctx, ...)
      return true
    end,

    ImGui_SetMouseCursor = function(ctx, ...)
      log_api_call("ImGui_SetMouseCursor", ctx, ...)
      return true
    end,

    ImGui_SetNextFrameWantCaptureKeyboard = function(ctx, ...)
      log_api_call("ImGui_SetNextFrameWantCaptureKeyboard", ctx, ...)
      return false
    end,

    ImGui_SetNextFrameWantCaptureMouse = function(ctx, ...)
      log_api_call("ImGui_SetNextFrameWantCaptureMouse", ctx, ...)
      return false
    end,

    ImGui_SetNextItemAllowOverlap = function(ctx, ...)
      log_api_call("ImGui_SetNextItemAllowOverlap", ctx, ...)
      return true
    end,

    ImGui_SetNextItemOpen = function(ctx, ...)
      log_api_call("ImGui_SetNextItemOpen", ctx, ...)
      return true
    end,

    ImGui_SetNextItemShortcut = function(ctx, ...)
      log_api_call("ImGui_SetNextItemShortcut", ctx, ...)
      return true
    end,

    ImGui_SetNextItemWidth = function(ctx, ...)
      log_api_call("ImGui_SetNextItemWidth", ctx, ...)
      return true
    end,

    ImGui_SetNextWindowBgAlpha = function(ctx, ...)
      log_api_call("ImGui_SetNextWindowBgAlpha", ctx, ...)
      return true
    end,

    ImGui_SetNextWindowContentSize = function(ctx, ...)
      log_api_call("ImGui_SetNextWindowContentSize", ctx, ...)
      return true
    end,

    ImGui_SetNextWindowDockID = function(ctx, ...)
      log_api_call("ImGui_SetNextWindowDockID", ctx, ...)
      return true
    end,

    ImGui_SetNextWindowPos = function(ctx, ...)
      log_api_call("ImGui_SetNextWindowPos", ctx, ...)
      return true
    end,

    ImGui_SetNextWindowSize = function(ctx, ...)
      log_api_call("ImGui_SetNextWindowSize", ctx, ...)
      return true
    end,

    ImGui_SetNextWindowSizeConstraints = function(ctx, ...)
      log_api_call("ImGui_SetNextWindowSizeConstraints", ctx, ...)
      return true
    end,

    ImGui_SetScrollFromPosX = function(ctx, ...)
      log_api_call("ImGui_SetScrollFromPosX", ctx, ...)
      return true
    end,

    ImGui_SetScrollFromPosY = function(ctx, ...)
      log_api_call("ImGui_SetScrollFromPosY", ctx, ...)
      return true
    end,

    ImGui_SetScrollHereX = function(ctx, ...)
      log_api_call("ImGui_SetScrollHereX", ctx, ...)
      return true
    end,

    ImGui_SetScrollHereY = function(ctx, ...)
      log_api_call("ImGui_SetScrollHereY", ctx, ...)
      return true
    end,

    ImGui_SetScrollX = function(ctx, ...)
      log_api_call("ImGui_SetScrollX", ctx, ...)
      return true
    end,

    ImGui_SetScrollY = function(ctx, ...)
      log_api_call("ImGui_SetScrollY", ctx, ...)
      return true
    end,

    ImGui_SetTooltip = function(ctx, ...)
      log_api_call("ImGui_SetTooltip", ctx, ...)
      return true
    end,

    ImGui_SetWindowFontScale = function(ctx, ...)
      log_api_call("ImGui_SetWindowFontScale", ctx, ...)
      return true
    end,

    ImGui_SetWindowSize = function(ctx, ...)
      log_api_call("ImGui_SetWindowSize", ctx, ...)
      return true
    end,

    ImGui_Shortcut = function(ctx, ...)
      log_api_call("ImGui_Shortcut", ctx, ...)
      return true
    end,

    ImGui_ShowAboutWindow = function(ctx, ...)
      log_api_call("ImGui_ShowAboutWindow", ctx, ...)
      return true
    end,

    ImGui_ShowDebugLogWindow = function(ctx, ...)
      log_api_call("ImGui_ShowDebugLogWindow", ctx, ...)
      return true
    end,

    ImGui_ShowFontAtlas = function(ctx, ...)
      log_api_call("ImGui_ShowFontAtlas", ctx, ...)
      return true
    end,

    ImGui_ShowFontSelector = function(ctx, ...)
      log_api_call("ImGui_ShowFontSelector", ctx, ...)
      return true
    end,

    ImGui_ShowIDStackToolWindow = function(ctx, ...)
      log_api_call("ImGui_ShowIDStackToolWindow", ctx, ...)
      return true
    end,

    ImGui_ShowMetricsWindow = function(ctx, ...)
      log_api_call("ImGui_ShowMetricsWindow", ctx, ...)
      return true
    end,

    ImGui_ShowStyleSelector = function(ctx, ...)
      log_api_call("ImGui_ShowStyleSelector", ctx, ...)
      return true
    end,

    ImGui_SliderAngle = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderAngle", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderDouble = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderDouble", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderDouble2 = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderDouble2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderDouble3 = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderDouble3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderDouble4 = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderDouble4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderDoubleN = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderDoubleN", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderInt = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderInt", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderInt2 = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderInt2", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderInt3 = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderInt3", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderInt4 = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderInt4", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SliderScalar = function(ctx, label, value, ...)
      log_api_call("ImGui_SliderScalar", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_SmallButton = function(ctx, ...)
      log_api_call("ImGui_SmallButton", ctx, ...)
      return true
    end,

    ImGui_Spacing = function(ctx, ...)
      log_api_call("ImGui_Spacing", ctx, ...)
      return true
    end,

    ImGui_StyleColorsClassic = function(ctx, label, value, ...)
      log_api_call("ImGui_StyleColorsClassic", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_StyleColorsDark = function(ctx, label, value, ...)
      log_api_call("ImGui_StyleColorsDark", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_StyleColorsLight = function(ctx, label, value, ...)
      log_api_call("ImGui_StyleColorsLight", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_TabItemButton = function(ctx, ...)
      log_api_call("ImGui_TabItemButton", ctx, ...)
      return true
    end,

    ImGui_TableAngledHeadersRow = function(ctx, ...)
      log_api_call("ImGui_TableAngledHeadersRow", ctx, ...)
      return true
    end,

    ImGui_TableFlags_NoBordersInBody = function(ctx, ...)
      log_api_call("ImGui_TableFlags_NoBordersInBody", ctx, ...)
      return true
    end,

    ImGui_TableFlags_NoBordersInBodyUntilResize = function(ctx, ...)
      log_api_call("ImGui_TableFlags_NoBordersInBodyUntilResize", ctx, ...)
      return true
    end,

    ImGui_TableGetColumnFlags = function(ctx, ...)
      log_api_call("ImGui_TableGetColumnFlags", ctx, ...)
      return true
    end,

    ImGui_TableGetColumnIndex = function(ctx, ...)
      log_api_call("ImGui_TableGetColumnIndex", ctx, ...)
      return true
    end,

    ImGui_TableGetColumnName = function(ctx, ...)
      log_api_call("ImGui_TableGetColumnName", ctx, ...)
      return true
    end,

    ImGui_TableGetColumnSortSpecs = function(ctx, ...)
      log_api_call("ImGui_TableGetColumnSortSpecs", ctx, ...)
      return true
    end,

    ImGui_TableGetRowIndex = function(ctx, ...)
      log_api_call("ImGui_TableGetRowIndex", ctx, ...)
      return true
    end,

    ImGui_TableHeader = function(ctx, ...)
      log_api_call("ImGui_TableHeader", ctx, ...)
      return true
    end,

    ImGui_TableHeadersRow = function(ctx, ...)
      log_api_call("ImGui_TableHeadersRow", ctx, ...)
      return true
    end,

    ImGui_TableNeedSort = function(ctx, ...)
      log_api_call("ImGui_TableNeedSort", ctx, ...)
      return true
    end,

    ImGui_TableNextColumn = function(ctx, ...)
      log_api_call("ImGui_TableNextColumn", ctx, ...)
      return true
    end,

    ImGui_TableNextRow = function(ctx, ...)
      log_api_call("ImGui_TableNextRow", ctx, ...)
      return true
    end,

    ImGui_TableSetBgColor = function(ctx, ...)
      log_api_call("ImGui_TableSetBgColor", ctx, ...)
      return true
    end,

    ImGui_TableSetColumnIndex = function(ctx, ...)
      log_api_call("ImGui_TableSetColumnIndex", ctx, ...)
      return true
    end,

    ImGui_TableSetupColumn = function(ctx, ...)
      log_api_call("ImGui_TableSetupColumn", ctx, ...)
      return true
    end,

    ImGui_TableSetupScrollFreeze = function(ctx, ...)
      log_api_call("ImGui_TableSetupScrollFreeze", ctx, ...)
      return true
    end,

    ImGui_Text = function(ctx, ...)
      log_api_call("ImGui_Text", ctx, ...)
      return true
    end,

    ImGui_TextColored = function(ctx, label, value, ...)
      log_api_call("ImGui_TextColored", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_TextDisabled = function(ctx, ...)
      log_api_call("ImGui_TextDisabled", ctx, ...)
      return false
    end,

    ImGui_TextFilter_Draw = function(draw_list, ...)
      log_api_call("ImGui_TextFilter_Draw", draw_list, ...)
      return true
    end,

    ImGui_TextFilter_IsActive = function(ctx, ...)
      log_api_call("ImGui_TextFilter_IsActive", ctx, ...)
      return false
    end,

    ImGui_TextFilter_PassFilter = function(ctx, ...)
      log_api_call("ImGui_TextFilter_PassFilter", ctx, ...)
      return true
    end,

    ImGui_TextUnformatted = function(ctx, ...)
      log_api_call("ImGui_TextUnformatted", ctx, ...)
      return true
    end,

    ImGui_TextWrapped = function(ctx, ...)
      log_api_call("ImGui_TextWrapped", ctx, ...)
      return true
    end,

    ImGui_TreeNode = function(ctx, label, ...)
      log_api_call("ImGui_TreeNode", ctx, label, ...)
      return false
    end,

    ImGui_TreeNodeEx = function(ctx, label, ...)
      log_api_call("ImGui_TreeNodeEx", ctx, label, ...)
      return false
    end,

    ImGui_TreePop = function(ctx, label, ...)
      log_api_call("ImGui_TreePop", ctx, label, ...)
      return false
    end,

    ImGui_Unindent = function(ctx, ...)
      log_api_call("ImGui_Unindent", ctx, ...)
      return true
    end,

    ImGui_VSliderDouble = function(ctx, label, value, ...)
      log_api_call("ImGui_VSliderDouble", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_VSliderInt = function(ctx, label, value, ...)
      log_api_call("ImGui_VSliderInt", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,

    ImGui_ValidatePtr = function(ctx, ...)
      log_api_call("ImGui_ValidatePtr", ctx, ...)
      return true
    end,

    ImGui_Viewport_GetCenter = function(ctx, ...)
      log_api_call("ImGui_Viewport_GetCenter", ctx, ...)
      return false
    end,

    ImGui_Viewport_GetPos = function(ctx, ...)
      log_api_call("ImGui_Viewport_GetPos", ctx, ...)
      return false
    end,

    ImGui_Viewport_GetWorkPos = function(ctx, ...)
      log_api_call("ImGui_Viewport_GetWorkPos", ctx, ...)
      return false
    end,

    ImGui_Viewport_GetWorkSize = function(ctx, ...)
      log_api_call("ImGui_Viewport_GetWorkSize", ctx, ...)
      return false
    end,

    ImGui_WindowFlags_NoBringToFrontOnFocus = function(ctx, ...)
      log_api_call("ImGui_WindowFlags_NoBringToFrontOnFocus", ctx, ...)
      return true
    end,

}

return generated_functions