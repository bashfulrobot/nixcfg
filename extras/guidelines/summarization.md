# Strategic LLM Usage for Transcript Processing and Meeting Summarization

## Overview

This guide outlines optimal LLM selection for processing meeting transcripts and generating high-quality summaries based on model capabilities, context handling, and reasoning strengths.

## Optimal Models for 16GB GPU (Quality-First Summarization)

### Primary Models for Transcript Processing

| Model | VRAM | Reasoning | Context | Primary Use |
|-------|------|-----------|---------|-------------|
| **Deepseek-Coder 33B** | ~18GB* | 9/10 | Very Good | **BEST OVERALL** - All meeting types, technical content |
| **Mistral 7B** | 8GB | 8/10 | Limited | Quick summaries, fallback option |

*Deepseek-Coder 33B may require CPU offloading on 16GB GPU

### Quality-First Strategy for Meeting Summaries

**Default Choice:** Use Deepseek-Coder 33B for all meeting summarization
- Excellent reasoning (9/10) for understanding complex discussions
- Superior at technical content and decision extraction
- Handles most meeting types exceptionally well

## Simplified Meeting Summarization Workflow (16GB GPU Optimized)

### Primary Workflow: Deepseek-Coder 33B for Everything

**Default Choice:** Use Deepseek-Coder 33B for all summarization tasks

**Why:** Best available model for your hardware that excels at reasoning
- Reasoning: 9/10 (excellent for complex meeting analysis)
- Context: Very good for long transcripts
- Versatility: Handles all meeting types and content well

**All Summarization Tasks:**
- Transcript cleanup and formatting
- Content analysis and theme identification
- Decision point extraction
- Action item identification
- Executive summary generation
- Technical meeting analysis
- Multi-participant discussion synthesis

**Example Workflow:**
```bash
# Use Deepseek-Coder for complete meeting processing
ollama run deepseek-coder:33b "Process this meeting transcript: clean it up, identify key decisions, extract action items, and create an executive summary..."

# For technical meetings
ollama run deepseek-coder:33b "Analyze this engineering meeting transcript for technical decisions, architecture discussions, and implementation plans..."

# For any meeting type
ollama run deepseek-coder:33b "Summarize this meeting with focus on outcomes, decisions, and next steps..."
```

### Fallback: Mistral 7B (When Deepseek Won't Fit)

**When to Use:**
- Deepseek-Coder 33B won't load due to memory constraints
- Very short meetings or simple standup summaries
- Need extremely fast processing for quick updates

**Tasks:**
- Basic transcript cleanup
- Simple daily standup summaries
- Quick meeting notes
- Short discussion summaries

**Example Workflow:**
```bash
# Fallback to Mistral for resource constraints
ollama run mistral:7b "Quickly summarize this short standup meeting with action items"
```

## Meeting Type Handling (Simplified)

### All Meeting Types → Deepseek-Coder 33B

**Executive/Board Meetings**
- Strategic decision extraction
- Executive summary with impact analysis
- Stakeholder action items

**Technical Architecture Reviews**
- Technical decision documentation
- Implementation plan extraction
- Risk and concern identification

**Daily Standups**
- Quick status summaries
- Blocker identification
- Next steps tracking

**Cross-Functional Planning**
- Multi-team coordination summary
- Dependency identification
- Timeline and milestone extraction

**International/Multi-Team Calls**
- Cross-cultural context preservation
- Multi-perspective synthesis
- Global coordination summaries

## Processing Strategies for 16GB GPU

### Single-Pass Processing (Recommended)
```
Deepseek-Coder 33B: Complete transcript → Final summary
```
- Most efficient for your hardware
- Best quality-to-resource ratio
- Handles all meeting complexities

### Large Meeting Segmentation (If Needed)
```
Segment 1: Deepseek-Coder 33B (analysis + summary)
Segment 2: Deepseek-Coder 33B (analysis + summary)
Final: Deepseek-Coder 33B (combine segment summaries)
```
- Use only if transcript exceeds context limits
- Each segment gets full processing treatment

## Memory Management for 16GB GPU

### Running Deepseek-Coder 33B on 16GB
```bash
# May need CPU offloading - slower but higher quality
ollama run deepseek-coder:33b --gpu-layers 20

# Alternative: Use quantized version if available
ollama run deepseek-coder:33b-q4
```

### Quick Model Aliases
```bash
# Easy switching for summarization tasks
alias summarize="ollama run deepseek-coder:33b"
alias quick-summary="ollama run mistral:7b"

# Usage examples
summarize "Create comprehensive meeting summary from: [transcript]"
quick-summary "Quick standup summary: [short transcript]"
```

### Context Management
- **Large Transcripts**: Break into logical segments, process each with Deepseek-Coder
- **Multi-Topic Meetings**: Use single comprehensive prompt with Deepseek-Coder
- **Real-Time Processing**: Use Mistral 7B for immediate updates, Deepseek-Coder for final summary

## Output Format Templates

### Executive Summary Template
```
MEETING: [Title] - [Date] - [Duration]
ATTENDEES: [Key participants and roles]

EXECUTIVE SUMMARY:
[2-3 sentence overview of meeting purpose and outcomes]

KEY DECISIONS:
1. [Decision] - [Owner] - [Timeline]
2. [Decision] - [Owner] - [Timeline]

ACTION ITEMS:
- [Task] - [Owner] - [Due Date] - [Priority]

NEXT STEPS:
[Follow-up meetings, deadlines, dependencies]
```

### Technical Meeting Template
```
TECHNICAL REVIEW: [Topic] - [Date]
PARTICIPANTS: [Engineers, architects, stakeholders]

TECHNICAL DECISIONS:
1. [Architecture/Design decision]
   - Rationale: [Why this approach]
   - Impact: [System/team effects]
   - Timeline: [Implementation schedule]

IMPLEMENTATION PLAN:
- [Phase 1]: [Description] - [Owner] - [Timeline]
- [Phase 2]: [Description] - [Owner] - [Timeline]

RISKS & CONCERNS:
- [Risk] - [Mitigation strategy] - [Owner]

FOLLOW-UP TECHNICAL REVIEWS:
[Scheduled reviews, decision points]
```

## Quality Metrics & Validation

### Summary Quality Indicators
1. **Accuracy**: All key decisions captured
2. **Completeness**: No missing action items
3. **Clarity**: Non-attendees can understand outcomes
4. **Actionability**: Clear next steps with owners

### Validation Process
1. **Fact-Check**: Compare summary against transcript
2. **Stakeholder Review**: Key participants validate accuracy
3. **Action Item Verification**: Confirm owners and timelines
4. **Decision Clarity**: Ensure decisions are unambiguous

## Quality vs Speed Trade-offs for Summarization

**High Quality (Slower):** Deepseek-Coder 33B
- Use for important meetings with stakeholders
- Complex technical discussions
- Strategic planning sessions
- Board meetings and executive reviews

**Fast Processing (Lower Quality):** Mistral 7B
- Use for daily standups
- Quick status updates
- Simple team check-ins
- When speed is more important than detail

## Simple Decision Process for Meeting Summaries

```
1. Is this a critical or complex meeting?
   → YES: Use Deepseek-Coder 33B (wait for quality)
   → NO: Continue to step 2

2. Need a quick summary or simple standup?
   → YES: Use Mistral 7B (fast feedback)
   → NO: Use Deepseek-Coder 33B anyway (better safe than sorry)
```

## Practical Integration for 16GB GPU

### Simplified Meeting Processor
```bash
#!/bin/bash
# meeting-processor-16gb.sh

# Single-step processing with Deepseek-Coder
ollama run deepseek-coder:33b "Process this meeting transcript into a comprehensive summary with executive overview, key decisions, action items, and next steps: $1" > summary.md
```

### Smart Meeting Router
```bash
# Simple decision logic for model selection
if [[ -f "$HOME/.quick-summary" ]]; then
    # Use fast processing flag
    ollama run mistral:7b "Quick meeting summary: $TRANSCRIPT"
else
    # Default to quality processing
    ollama run deepseek-coder:33b "Comprehensive meeting summary: $TRANSCRIPT"
fi
```

### Aliases for Common Tasks
```bash
# Meeting summary aliases
alias meeting-summary="ollama run deepseek-coder:33b"
alias quick-standup="ollama run mistral:7b"
alias technical-meeting="ollama run deepseek-coder:33b"

# Usage examples
meeting-summary "Summarize this board meeting transcript..."
quick-standup "Quick daily standup summary..."
technical-meeting "Analyze this architecture review meeting..."
```

## Best Practices for 16GB GPU Summarization

### Prompt Engineering
1. **Comprehensive Single Prompts**: Include all requirements in one prompt for Deepseek-Coder
2. **Clear Output Structure**: Specify exactly what format you want
3. **Context Preservation**: Ask for speaker attribution and decision ownership
4. **Action Orientation**: Always request clear next steps and action items

### Quality Assurance
1. **Template Consistency**: Use standardized prompts for similar meeting types
2. **Output Validation**: Check that all key decisions and actions are captured
3. **Stakeholder Review**: Have key participants validate important summaries
4. **Iterative Improvement**: Refine prompts based on feedback

### Efficiency Tips
1. **Single-Pass Processing**: Use Deepseek-Coder for complete processing in one step
2. **Model Switching**: Only use Mistral 7B when absolutely necessary for speed
3. **Memory Management**: Use GPU layer limiting if needed for Deepseek-Coder
4. **Batch Processing**: Process multiple short meetings together when possible

## Conclusion

For 16GB GPU setups prioritizing quality meeting summaries:
- **Default:** Deepseek-Coder 33B for all important meetings and complex discussions
- **Fallback:** Mistral 7B only for quick standups or when memory is constrained
- **Strategy:** Accept slower processing for significantly better summary quality and accuracy
- **Key Insight:** One high-quality model handling all tasks is simpler and more effective than complex multi-model workflows