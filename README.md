# Deep Research - Self-Spawning Agents

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Claude Code agents that spawn their own sub-agents.**

```bash
./deep-research.sh "Why do startups fail?"
```

Agent decides it needs help → spawns sub-agents → they can spawn more → results flow back up.

## What happens

```
You: "Why do startups fail?"
    │
    └── Coordinator (Opus): "Multiple angles needed"
            ├── Researcher 1 (Sonnet): founder issues
            │       └── Sub-researcher: psychology of failure
            ├── Researcher 2 (Sonnet): market problems
            ├── Researcher 3 (Sonnet): financial issues
            └── Researcher 4 (Sonnet): team dynamics
                    │
                    ▼
            Synthesized report
```

Each agent inherits "DNA" - the instruction to break down OR answer directly. Same logic at every level. Unlimited depth. It stops when questions become atomic.

## Install

```bash
git clone https://github.com/Cranot/deep-research.git
cd deep-research
chmod +x *.sh
```

Needs [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed.

## Use

```bash
# Best quality: Opus orchestrator + Sonnet researchers (default)
./deep-research.sh "What makes great software architecture?"

# With web search for current information
./deep-research.sh --web "What are the latest AI agent frameworks?"

# Fast & cheap: Sonnet orchestrator + Haiku researchers
./deep-research.sh -m sonnet -r haiku "Why do startups fail?"

# All Opus (expensive but thorough)
./deep-research.sh -m opus -r opus --web "Deep analysis of market trends"
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-m, --model` | Orchestrator model (opus, sonnet, haiku) | opus |
| `-r, --researcher` | Sub-agent model (opus, sonnet, haiku) | sonnet |
| `-w, --web` | Enable web search for agents | off |
| `-h, --help` | Show help | - |

Reports are saved to `reports/YYYY-MM-DD-question-slug/SYNTHESIS.md`

## How it works

The trick is `--allowedTools "Bash(claude:*)"` which lets spawned Claude instances spawn more instances.

Each agent:
1. Gets a question + DNA (recursive spawning instructions)
2. Asks: "Are there multiple angles worth exploring?"
3. If YES → spawns sub-agents for each angle, waits, synthesizes
4. If NO → answers directly
5. Sub-agents inherit the same DNA and can spawn more

The DNA biases toward exploration: "Go deep, not shallow."

## The DNA

This is the recursive instruction every agent inherits:

```
=== AGENT DNA (every sub-agent inherits this) ===
Before answering, ALWAYS ask: are there multiple angles worth exploring?
- If YES: spawn a sub-agent for each angle, wait for results, then synthesize
- If NO: Answer directly.
Bias toward exploring more angles. Go deep, not shallow.
=== END DNA ===
```

`--allowedTools 'Bash(claude:*)'` pre-authorizes spawning more Claude instances.

## Examples

Sample reports from actual runs:

- **"What makes great software architecture?"** - Sonnet + Haiku researchers explored 6 dimensions: technical excellence, human alignment, business value, context-dependence, evolution, decision-making
- **"How do multi-agent AI systems coordinate?"** - Opus coordinator discovered a 4-layer coordination stack (protocols → architectures → state systems → emergence)

Reports are saved to `reports/` folder with timestamps.

## Cost

This spawns multiple Claude instances. Cost varies by model choice:

| Configuration | Typical Cost | Use Case |
|--------------|--------------|----------|
| `-m opus -r sonnet` (default) | $1-5 | Best quality |
| `-m sonnet -r haiku` | $0.10-0.50 | Fast & cheap |
| `-m opus -r opus --web` | $5-15 | Deep + current info |

Depends on question complexity and how deep agents decide to go.

## Built by

[AgentsKB](https://agentskb.com)

## License

MIT
