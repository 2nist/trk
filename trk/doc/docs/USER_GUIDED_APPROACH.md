# User-Guided Approach to Music Production Tools

## Core Philosophy

The Groove MIDI Machine (GMM) and related Songbase tools follow a **user-guided approach** to music production assistance. This document outlines what this approach means in practice and how it shapes our tool design.

## What "User-Guided" Means

In our context, "user-guided" means:

1. **Users Direct the Creative Process**: The creative decisions and direction always come from the user, not the software
2. **Tools Provide Assistance, Not Automation**: Our tools help organize, suggest, and provide insights rather than automatically generating music
3. **Transparent Decision Support**: When suggestions are provided, they come with clear explanations of their musical characteristics
4. **Human-Centered Design**: The interface is designed around the user's creative workflow, not algorithmic processes
5. **Control Over Convenience**: We prioritize giving users control over making things "automatic"

## What Our Tools Don't Do

- They don't generate drum patterns or musical ideas from scratch
- They don't make creative decisions without user input
- They don't apply changes or select patterns automatically
- They don't hide the reasoning behind suggestions
- They don't try to replace human musical intuition

## Practical Implementation

This philosophy is implemented through specific design patterns:

### User-Initiated Actions

All significant actions require explicit user initiation:

- Pattern suggestions are only provided when requested
- No automatic pattern selection or application
- User must explicitly ask for assistance

### Transparent Information

When providing suggestions:

- Clear explanation of pattern characteristics
- Visual representation of pattern energy, complexity, etc.
- Confidence ratings that acknowledge uncertainty
- Multiple options with reasoning for each

### Control Granularity

Users can work at their preferred level of detail:

- Full pattern selection for a quick workflow
- Component-level editing for detailed control
- Parameter adjustments for fine-tuning
- Direct MIDI editing when needed

### Learning, Not Replacing

Our tools are designed to help users:

- Discover patterns they might not have found otherwise
- Learn about pattern relationships and musical structures
- Develop their own creative instincts
- Save time on organizational tasks, not creative ones

## Example Workflow

A typical user-guided workflow might look like:

1. User browses pattern library, selecting patterns they like
2. User defines the song structure manually
3. User requests suggestions for a specific section
4. System provides multiple pattern options with explanations
5. User selects, modifies, or rejects the suggestions
6. User fine-tunes patterns using the editing tools
7. User arranges patterns to form the final drum track

At each step, the system provides information and organization to support the user's creative decisions, but never makes those decisions automatically.

## Design Guidelines for Developers

When extending the GMM or related tools:

1. Always make suggestion features user-initiated, never automatic
2. Provide clear explanations for any suggestions or analyses
3. Offer multiple options rather than a single "best" answer
4. Make all parameters user-adjustable
5. Prioritize transparency and control over automation
6. Remember that the user is the musician, and the tool is just an assistant
