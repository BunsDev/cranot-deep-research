# Deep Research

**Fractal exploration of any question through recursive AI agents.**

A question spawns angles. Each angle spawns deeper angles. The tree grows until questions become atomic — then everything synthesizes back up into one comprehensive answer.

```
Question: "Why do smart people make bad decisions?"
    │
    ├── What cognitive biases affect intelligent people?
    │       ├── How does overconfidence manifest in experts?
    │       ├── What is the curse of knowledge?
    │       └── ... (each can branch further)
    │
    ├── How does expertise create blind spots?
    │       └── ...
    │
    └── What role does emotional reasoning play?
            └── ...

            ↓ ALL BRANCHES EXPLORED IN PARALLEL ↓
            ↓ SYNTHESIZE BACK UP THE TREE ↓

                  [Comprehensive Answer]
```

---

## Features

- **7 LLM Providers**: Claude, Gemini, OpenAI/Azure, OpenRouter (Grok), Kimi
- **4 Research Strategies**: Recursive, Socratic, Perspective-based, Grounded (web-verified)
- **Multi-model Ensembles**: Multiple models answer, then merge perspectives
- **Web Search Grounding**: Verify claims with live web search
- **Parallel Execution**: Concurrent agents with configurable limits
- **Persistent Checkpoints**: Resume interrupted research
- **Typed Knowledge Graphs**: Track epistemic state of every finding

---

## Installation

```bash
# Clone the repository
git clone https://github.com/Cranot/deep-research.git
cd deep-research

# Install as Python package
pip install -e .

# Or with development dependencies
pip install -e ".[dev]"
```

### Environment Variables

Create a `.env` file:

```bash
# Required: At least one provider
ANTHROPIC_API_KEY=your-key      # Claude (recommended)

# Optional: Additional providers
GEMINI_API_KEY=your-key         # Gemini
GPT5_MINI_API_KEY=your-key      # Azure OpenAI
GPT5_MINI_ENDPOINT=your-endpoint
OPENROUTER_API_KEY=your-key     # OpenRouter (Grok)
KIMI_API_KEY=your-key           # Kimi (FREE, best merger)
KIMI_ENDPOINT=your-endpoint
```

---

## Quick Start

### Python CLI (Recommended)

```bash
# Basic research
deep-research research "What makes startups successful?"

# With depth limit (recommended: 2)
deep-research research -d 2 "Your question"

# Socratic mode - improve questions before researching
deep-research socratic "How do I become more productive?"

# Perspective expansion - multi-angle analysis
deep-research perspectives "What makes good leadership?"

# Grounded research - web-verified answers
deep-research research --strategy grounded_research "Current state of AI"
```

### Python API

```python
import asyncio
from deep_research.core import MasterChef, grounded_research_strategy
from pathlib import Path

async def main():
    chef = MasterChef(
        output_dir=Path("reports/my-research"),
        max_parallel=10,
    )

    result = await chef.cook(
        "What makes startups successful?",
        "recursive_research",  # or pass strategy object
        context={"model": "haiku"}
    )

    print(result.final_synthesis.content)

asyncio.run(main())
```

### Legacy Bash (Still Works)

```bash
./deep-research.sh "Your question"
./deep-research.sh -d 2 -m opus -r haiku "Your question"
```

---

## Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| `recursive_research` | Decompose → Answer → Synthesize | General research |
| `socratic` | Challenge assumptions, find better questions | Unclear problems |
| `perspective_expander` | Multi-angle analysis with blind spot detection | Complex topics |
| `grounded_research` | Web-verified answers | Fact-checking, current events |

```bash
# Use a specific strategy
deep-research research --strategy grounded_research "Your question"
```

---

## Model Configuration

### Format

```
provider:model   →  gemini:flash, claude:opus
model            →  defaults to Claude (haiku = claude:haiku)
```

### Supported Models

| Provider | Models | Notes |
|----------|--------|-------|
| **Claude** | `opus`, `sonnet`, `haiku` | Best orchestrator (opus) |
| **Gemini** | `flash`, `pro` | Fast, cost-effective leaves |
| **OpenAI/Azure** | `gpt5-mini` | Requires temperature=1.0 |
| **OpenRouter** | `grok`, `grok-3`, `grok-4` | Via x-ai |
| **Kimi** | `kimi` | FREE, best merger (9.5/10) |

### Recommended Configurations

```bash
# Quality-focused (recommended)
deep-research research -m opus -r haiku -d 2 "Your question"

# Cost-optimized with ensemble
deep-research research -l "haiku,gemini:flash" --merger kimi:kimi "Your question"

# All-Gemini
deep-research research -m gemini:pro -r gemini:flash "Your question"

# With web search grounding
deep-research research --strategy grounded_research -m haiku "Current AI news"
```

---

## CLI Options

```bash
deep-research research [OPTIONS] "Your question"
```

| Flag | Default | Description |
|------|---------|-------------|
| `-m, --model` | opus | Orchestrator model |
| `-r, --researcher` | haiku | Researcher model |
| `-l, --leaves` | (use -r) | Leaf ensemble (comma-separated) |
| `--merger` | (use -m) | Model for merging ensembles |
| `-d, --depth` | 0 | Max depth (0 = unlimited) |
| `-p, --parallel` | 10 | Max concurrent agents |
| `-w, --web` | off | Enable web search |
| `-o, --output` | auto | Output directory |
| `--strategy` | recursive_research | Strategy name |

---

## Architecture

```
src/deep_research/
├── core/                    # MasterChef framework
│   ├── node.py              # Typed nodes, epistemic states
│   ├── graph.py             # Knowledge graphs with persistence
│   ├── operation.py         # Operation protocol
│   ├── strategy.py          # Declarative strategies
│   ├── chef.py              # MasterChef orchestrator
│   └── operations/          # Concrete operations
│       ├── decompose.py     # DECOMPOSE: Question → Sub-questions
│       ├── answer.py        # ANSWER: Question → Answer
│       ├── synthesize.py    # SYNTHESIZE: Findings → Synthesis
│       ├── detect.py        # DETECT: Blind spots, tensions
│       └── ground.py        # GROUND: Web-verified claims
├── providers/               # LLM integrations
│   ├── claude.py            # Claude CLI (subscription-based)
│   ├── gemini.py            # Gemini API
│   ├── openai_azure.py      # Azure OpenAI
│   ├── openrouter.py        # OpenRouter
│   └── kimi.py              # Kimi
├── recipes/                 # Research methodologies
│   ├── perspective.py       # Perspective expansion
│   └── socratic.py          # Socratic questioning
└── cli.py                   # Typer CLI
```

### Key Concepts

**Nodes**: Typed content units (Question, Answer, Insight, BlindSpot, etc.) with epistemic status (Unknown → Explored → Validated → Synthesized)

**Operations**: Epistemic transitions (DECOMPOSE, ANSWER, SYNTHESIZE, GROUND, etc.)

**Strategies**: Declarative recipes that orchestrate operations

**MasterChef**: Executes strategies on knowledge graphs

---

## Output

Reports save to:

```
reports/YYYY-MM-DD-your-question-slug/
├── SYNTHESIS.md              # Final report
├── PERSPECTIVES.md           # Perspective analysis (if used)
├── SOCRATIC.md               # Question evolution (if used)
├── graph.json                # Knowledge graph checkpoint
└── agents/                   # Individual agent outputs
    ├── d0-001-opus.md
    ├── d1-002-haiku.md
    └── ...
```

---

## Key Insights

1. **Multi-model merges beat single models** — Ensembling 4+ diverse outputs produces higher quality than any single model
2. **Best merger: Kimi-K2-Thinking** — 9.5/10 quality AND free via Azure AI Services
3. **Cheap models ensemble well** — haiku + flash as leaves, kimi as merger = best cost/quality
4. **Every question contains hidden angles** — Recursive exploration surfaces what you'd never think to ask

---

## Related

- **[CLAUDE.md](CLAUDE.md)** — Full technical reference
- **[RECIPES.md](RECIPES.md)** — 156 research patterns
- **[AgentsKB](https://agentskb.com)** — Pre-researched knowledge for AI agents

---

## License

MIT

---

<p align="center">
  <b>Deep Research</b> - Fractal exploration through recursive AI agents<br>
  Made by <a href="https://github.com/Cranot">Dimitris Mitsos</a> & <a href="https://agentskb.com">AgentsKB.com</a>
</p>
