# NarrativeVote

A collaborative storytelling platform for plot development and character decisions built on the Stacks blockchain using Clarity smart contracts.

## Description

NarrativeVote enables users to create interactive stories, develop characters collaboratively, and make plot decisions through community voting. Story creators can invite collaborators to contribute to character development and plot progression, while the community votes on key narrative decisions that shape the story's direction.

## Features

- **Story Creation**: Create and manage interactive stories with titles, descriptions, and genre classifications
- **Collaborative Development**: Add collaborators with specific roles to contribute to story development
- **Character Management**: Create detailed characters with names, descriptions, and traits
- **Democratic Plot Decisions**: Create voting polls for plot decisions with two options
- **Community Voting**: Users can vote on plot decisions to influence story direction
- **Automatic Resolution**: Plot decisions are automatically resolved based on voting results
- **Access Control**: Role-based permissions for story creators and collaborators

## Technical Specifications

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity v2.5
- **Epoch**: 2.5
- **Testing Framework**: Vitest with Clarinet SDK
- **Development Environment**: Clarinet

### Contract Structure

The smart contract includes the following main data structures:

- **Stories**: Core story entities with metadata and creator information
- **Characters**: Character profiles linked to specific stories
- **Plot Decisions**: Voting polls for narrative choices
- **User Votes**: Individual vote records for tracking participation
- **Story Collaborators**: Role-based access control for story contributors

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- Node.js (v16 or later)
- npm or yarn package manager

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd NarrativeVote
```

2. Install dependencies:
```bash
cd NarrativeVote_contract
npm install
```

3. Verify installation:
```bash
clarinet check
```

## Usage Examples

### Creating a Story

```clarity
(contract-call? .NarrativeVote create-story
  "The Dragon's Quest"
  "An epic fantasy adventure where heroes must decide the fate of kingdoms"
  "Fantasy")
```

### Adding a Collaborator

```clarity
(contract-call? .NarrativeVote add-collaborator
  u1
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7
  "co-writer")
```

### Creating a Character

```clarity
(contract-call? .NarrativeVote create-character
  u1
  "Aria Stormwind"
  "A brave elven warrior with mastery over wind magic"
  "Courageous, loyal, quick-tempered")
```

### Creating a Plot Decision

```clarity
(contract-call? .NarrativeVote create-plot-decision
  u1
  "The Dragon's Lair"
  "Our heroes approach the ancient dragon. What should they do?"
  "Attempt to negotiate with the dragon"
  "Launch a surprise attack on the dragon"
  u144) ;; Voting period of 144 blocks (~24 hours)
```

### Voting on a Decision

```clarity
(contract-call? .NarrativeVote vote-on-decision u1 "a")
```

### Resolving a Decision

```clarity
(contract-call? .NarrativeVote resolve-decision u1)
```

## Contract Functions Documentation

### Public Functions

#### Story Management
- `create-story(title, description, genre)` - Create a new story
- `add-collaborator(story-id, collaborator, role)` - Add a collaborator to a story

#### Character Development
- `create-character(story-id, name, description, traits)` - Create a character for a story

#### Plot Decision System
- `create-plot-decision(story-id, title, description, option-a, option-b, voting-duration)` - Create a voting poll for plot decisions
- `vote-on-decision(decision-id, option)` - Vote on a plot decision (option: "a" or "b")
- `resolve-decision(decision-id)` - Resolve a plot decision after voting period ends

### Read-Only Functions

#### Data Retrieval
- `get-story(story-id)` - Get story details
- `get-character(character-id)` - Get character details
- `get-plot-decision(decision-id)` - Get plot decision details
- `get-user-vote(decision-id, voter)` - Get user's vote on a decision

#### Status Checks
- `has-voted(decision-id, voter)` - Check if user has voted on a decision
- `is-collaborator(story-id, user)` - Check if user is a collaborator on a story

#### Statistics
- `get-story-count()` - Get total number of stories created
- `get-character-count()` - Get total number of characters created
- `get-decision-count()` - Get total number of plot decisions created

### Error Codes

- `u100` - ERR-NOT-AUTHORIZED: User lacks permission for the operation
- `u101` - ERR-STORY-NOT-FOUND: Specified story does not exist
- `u102` - ERR-CHARACTER-NOT-FOUND: Specified character does not exist
- `u103` - ERR-DECISION-NOT-FOUND: Specified plot decision does not exist
- `u104` - ERR-ALREADY-VOTED: User has already voted on this decision
- `u105` - ERR-VOTING-ENDED: Voting period has ended
- `u106` - ERR-INSUFFICIENT-VOTES: Not enough votes to resolve decision
- `u107` - Invalid voting option (must be "a" or "b")

## Testing

Run the test suite:

```bash
npm test
```

Run tests with coverage and cost analysis:

```bash
npm run test:report
```

Watch mode for development:

```bash
npm run test:watch
```

## Deployment Guide

### Local Development

1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy contract:
```clarity
::deploy_contract NarrativeVote contracts/NarrativeVote.clar
```

### Testnet Deployment

1. Configure testnet settings in `settings/Testnet.toml`

2. Deploy to testnet:
```bash
clarinet deployments apply --testnet
```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`

2. Deploy to mainnet:
```bash
clarinet deployments apply --mainnet
```

## Security Notes

### Access Control
- Story creators have full control over their stories
- Only story creators can add collaborators
- Only story creators and collaborators can create characters and plot decisions
- All users can vote on plot decisions

### Voting Integrity
- Users can only vote once per decision
- Voting is time-limited based on block height
- Decisions can only be resolved after the voting period ends
- Vote tallying is transparent and immutable

### Data Validation
- String length limits prevent excessive storage usage
- Input validation ensures data integrity
- Principal-based authentication prevents unauthorized access

### Best Practices
- Always verify user permissions before allowing modifications
- Check voting periods before accepting votes
- Validate all input parameters for appropriate types and lengths
- Use block height for time-based operations to ensure consensus

## License

This project is licensed under the ISC License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Support

For questions, issues, or contributions, please open an issue on the project repository.