#!/bin/bash
# Deep Research - Hierarchical Agent Exploration
# https://github.com/Cranot/deep-research
#
# Turn any question into multi-agent exploration.
# Agents autonomously decide to break down complex questions
# or answer directly when atomic.

set -e

# Defaults
ORCHESTRATOR="opus"
RESEARCHER="sonnet"
WEB_SEARCH=false

show_help() {
    cat << 'EOF'
Deep Research - Hierarchical Agent Exploration

USAGE:
    ./deep-research.sh [options] "Your question"

OPTIONS:
    -m, --model MODEL       Orchestrator model: opus (default), sonnet, haiku
    -r, --researcher MODEL  Sub-agent model: opus, sonnet (default), haiku
    -w, --web               Enable web search for agents
    -h, --help              Show this help

EXAMPLES:
    # Best quality: Opus orchestrator + Sonnet researchers (default)
    ./deep-research.sh "What makes people buy vs just admire?"

    # With web search for current information
    ./deep-research.sh --web "What are the latest AI agent frameworks?"

    # Fast & cheap: Sonnet + Haiku
    ./deep-research.sh -m sonnet -r haiku "Why do startups fail?"

    # All Opus (expensive but thorough)
    ./deep-research.sh -m opus -r opus --web "Deep analysis of X"

HOW IT WORKS:
    1. Your question goes to a coordinator agent
    2. Agent decides: complex → spawn sub-agents, atomic → answer
    3. Sub-agents follow the same rule (recursive, unlimited depth)
    4. Results synthesize back up the chain
    5. Final report saved to reports/ folder

REQUIREMENTS:
    - Claude CLI installed (claude command available)
    - API access configured

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -m|--model)
            ORCHESTRATOR="$2"
            shift 2
            ;;
        -r|--researcher)
            RESEARCHER="$2"
            shift 2
            ;;
        -w|--web)
            WEB_SEARCH=true
            shift
            ;;
        *)
            QUESTION="$1"
            shift
            ;;
    esac
done

if [ -z "$QUESTION" ]; then
    show_help
fi

# Build allowed tools based on flags
if [ "$WEB_SEARCH" = true ]; then
    TOOLS="Bash(claude:*),WebSearch,WebFetch"
    RESEARCH_METHOD="Use WebSearch and WebFetch for current information."
else
    TOOLS="Bash(claude:*)"
    RESEARCH_METHOD="Answer from your knowledge."
fi

# Generate folder name from question
SLUG=$(echo "$QUESTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)
DATE=$(date '+%Y-%m-%d')

# Create research folder
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORT_DIR="${SCRIPT_DIR}/reports/${DATE}-${SLUG}"
mkdir -p "$REPORT_DIR"

OUTPUT_FILE="${REPORT_DIR}/SYNTHESIS.md"

echo "=== Deep Research ===" >&2
echo "Question: $QUESTION" >&2
echo "Orchestrator: $ORCHESTRATOR" >&2
echo "Researchers: $RESEARCHER" >&2
echo "Web search: $WEB_SEARCH" >&2
echo "Output: $OUTPUT_FILE" >&2
echo "====================" >&2
echo "" >&2

# The prompt with recursive DNA
PROMPT="QUESTION: \"$QUESTION\"

You are a research agent. You can spawn sub-agents to explore deeper.

=== AGENT DNA (every sub-agent inherits this) ===
Before answering, ALWAYS ask: are there multiple angles worth exploring?
- If YES: spawn a sub-agent for each angle, wait for results, then synthesize
- If NO: $RESEARCH_METHOD Answer directly.
Bias toward exploring more angles. Go deep, not shallow.
=== END DNA ===

TO SPAWN A SUB-AGENT:
claude -p 'QUESTION: \"[sub-question]\"

You are a research agent. Before answering, ask: are there multiple angles?
If YES: spawn sub-agents for each. If NO: answer directly.
To spawn more: claude -p \"QUESTION: [q] You are a research agent...\" --model $RESEARCHER --output-format text --allowedTools $TOOLS

$RESEARCH_METHOD' --model $RESEARCHER --output-format text --allowedTools '$TOOLS'

After spawning all sub-agents, wait for them, then synthesize their findings.

What angles does this question need explored?"

# Write header
echo "# $QUESTION" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "> Generated $(date '+%Y-%m-%d %H:%M') | Orchestrator: $ORCHESTRATOR | Researchers: $RESEARCHER | Web: $WEB_SEARCH" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Run and save
claude -p "$PROMPT" --model "$ORCHESTRATOR" --output-format text --allowedTools "$TOOLS" | tee -a "$OUTPUT_FILE"

echo "" >&2
echo "=== Research saved to $OUTPUT_FILE ===" >&2
