# 🧠 NeuralFund: AI-Powered Decentralized Venture Platform

NeuralFund revolutionizes venture funding by combining AI-driven project validation with blockchain transparency. Built on the Stacks blockchain, it enables entrepreneurs to launch AI/tech ventures with milestone-based funding and automated investor protection.

## 🚀 Features

### For Founders
- **Launch Neural Ventures**: Create AI-powered projects with detailed vision statements
- **Milestone-Based Development**: Structure projects into validated development phases
- **Automated Fund Release**: Receive funding as you complete development milestones
- **Transparent Progress Tracking**: Show investors real-time development progress

### For Investors
- **Smart Investment Protection**: Automatic refunds for failed ventures
- **Milestone Validation**: Funds released only when development phases are completed
- **Transparent Venture Analytics**: Full visibility into project progress and funding status
- **Risk Mitigation**: Built-in deadline enforcement and failure detection

### Platform Features
- **Decentralized Governance**: No central authority controls fund releases
- **Immutable Records**: All transactions and milestones recorded on blockchain
- **STX Integration**: Native Stacks token support for investments and withdrawals
- **Gas-Efficient Operations**: Optimized Clarity smart contract design

## 📋 Smart Contract Architecture

### Core Data Structures

#### Neural Ventures
```clarity
{
  founder: principal,
  project-name: string-utf8,
  vision-statement: string-utf8,
  funding-goal: uint,
  capital-raised: uint,
  launch-deadline: uint,
  is-live: bool,
  is-finalized: bool,
  development-phases: list of validated milestones
}
```

#### Investment Tracking
```clarity
{
  investment-amount: uint,
  funds-withdrawn: bool
}
```

### Key Functions

| Function | Description | Access |
|----------|-------------|--------|
| `launch-neural-venture` | Create new AI venture with milestones | Public |
| `neural-invest` | Invest STX tokens in active ventures | Public |
| `validate-phase` | Mark development milestone as complete | Founder Only |
| `finalize-venture` | Complete successful venture | Founder Only |
| `withdraw-investment` | Reclaim funds from failed ventures | Investor Only |
| `close-failed-venture` | Mark venture as failed past deadline | Public |

## 🛠 Installation & Setup

### Prerequisites
- [Stacks CLI](https://docs.stacks.co/docs/stacks-cli) installed
- [Clarinet](https://github.com/hirosystems/clarinet) for testing
- Node.js 16+ for frontend integration

### Local Development

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/neuralfund.git
cd neuralfund
```

2. **Initialize Clarinet project**
```bash
clarinet new neuralfund
cd neuralfund
```

3. **Add the smart contract**
```bash
# Copy the contract to contracts/neuralfund.clar
cp ../neuralfund.clar contracts/
```

4. **Configure Clarinet.toml**
```toml
[contracts.neuralfund]
path = "contracts/neuralfund.clar"
depends_on = []
```

5. **Run tests**
```bash
clarinet test
```

### Deployment

#### Testnet Deployment
```bash
clarinet deploy --testnet
```

#### Mainnet Deployment
```bash
clarinet deploy --mainnet
```

## 📖 Usage Examples

### Launching a Neural Venture

```clarity
;; Launch an AI startup focused on computer vision
(contract-call? .neuralfund launch-neural-venture
  u"VisionAI Startup"
  u"Revolutionary computer vision platform for autonomous vehicles"
  u1000000  ;; 1M STX funding goal
  u144000   ;; ~100 days deadline
  (list
    { phase-description: u"MVP Development", funding-required: u300000 }
    { phase-description: u"Beta Testing", funding-required: u200000 }
    { phase-description: u"Market Launch", funding-required: u500000 }
  )
)
```

### Making an Investment

```clarity
;; Invest 50,000 STX in venture ID 1
(contract-call? .neuralfund neural-invest u1 u50000)
```

### Validating Development Phase

```clarity
;; Founder validates completion of phase 0 (MVP Development)
(contract-call? .neuralfund validate-phase u1 u0)
```

### Withdrawing from Failed Venture

```clarity
;; Investor withdraws funds from failed venture
(contract-call? .neuralfund withdraw-investment u1)
```

## 🔒 Security Features

- **Access Control**: Function-level permissions for founders vs investors
- **Input Validation**: Comprehensive parameter checking on all functions
- **Reentrancy Protection**: Safe fund transfer patterns
- **Deadline Enforcement**: Automatic failure detection for expired ventures
- **Double-Spending Prevention**: Investment tracking prevents duplicate withdrawals

## 🧪 Testing

### Unit Tests
```bash
clarinet test tests/neuralfund_test.ts
```

### Integration Tests
```bash
clarinet integrate tests/integration/
```

### Test Coverage
- ✅ Venture creation and validation
- ✅ Investment flows and edge cases  
- ✅ Milestone validation workflows
- ✅ Refund mechanisms
- ✅ Access control enforcement
- ✅ Error handling scenarios

## 🤝 Contributing

We welcome contributions from the community.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Implement your feature
5. Run the test suite (`clarinet test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📊 Error Codes Reference

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `ERR-ACCESS-DENIED` | Unauthorized function access |
| 101 | `ERR-BALANCE-INSUFFICIENT` | Insufficient funds for operation |
| 102 | `ERR-VENTURE-NOT-FOUND` | Venture ID does not exist |
| 103 | `ERR-FUNDING-ROUND-CLOSED` | Investment period has ended |
| 104 | `ERR-MILESTONE-VALIDATED` | Development phase already completed |
| 105 | `ERR-INVALID-MILESTONE-ID` | Invalid development phase index |
| 106 | `ERR-NO-WITHDRAWAL-RIGHTS` | No funds available for withdrawal |
| 107 | `ERR-ALREADY-WITHDRAWN` | Funds already withdrawn |
| 108 | `ERR-VENTURE-SUCCESSFUL` | Cannot withdraw from successful venture |
| 109 | `ERR-INVALID-PARAMETERS` | Invalid input parameters |
| 110 | `ERR-MILESTONES-INCOMPLETE` | Not all development phases completed |

## 📈 Roadmap

### Phase 1
- [x] Core smart contract implementation
- [x] Basic testing suite
- [ ] Frontend web application
- [ ] Testnet deployment

### Phase 2
- [ ] AI integration for project validation
- [ ] Advanced analytics dashboard
- [ ] Mobile application
- [ ] Mainnet launch

### Phase 3
- [ ] Multi-token support (beyond STX)
- [ ] Governance token implementation
- [ ] Cross-chain bridge integration
- [ ] Enterprise features

## 📄 License

This project is licensed under the MIT License.


## 🎯 Built With

- **Stacks Blockchain**: Layer-1 blockchain that settles on Bitcoin
- **Clarity Language**: Smart contract language for predictable, secure code
- **STX Token**: Native cryptocurrency for the Stacks ecosystem