# MotivAid

A mobile health (mHealth) application for midwives and frontline healthcare workers to support early detection, prevention, and management of postpartum hemorrhage (PPH) using the WHO-endorsed **E-MOTIVE** clinical bundle.

## 🎯 Purpose

MotivAid bridges the gap between clinical guidelines and real-time practice in low-resource and low-connectivity settings, with emphasis on:

- **Offline-first** architecture
- **Structured workflows** based on E-MOTIVE
- **Real-time decision support**
- **Automatic documentation** and audits

## 🏗️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (Dart) |
| State Management | Riverpod |
| Backend | Supabase (Auth, PostgreSQL, Storage) |
| Local Storage | Hive + SQLite |
| Architecture | Clean Architecture |

## 📁 Project Structure

```
lib/
├── core/           # Core utilities, config, theme
├── features/       # Feature modules (auth, clinical, training)
├── shared/         # Shared widgets, models, services
└── l10n/           # Localization
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [PRD](docs/PRD.md) | Product requirements |
| [Architecture](docs/ARCHITECTURE.md) | System design |
| [Modules](docs/MODULES.md) | Features breakdown |
| [User Roles](docs/USER_ROLES.md) | Roles & permissions |
| [Database Schema](docs/DATABASE_SCHEMA.md) | Data model |
| [API Design](docs/API_DESIGN.md) | API documentation |
| [Development Guidelines](docs/DEVELOPMENT_GUIDELINES.md) | Coding standards |
| [Implementation Plan](docs/IMPLEMENTATION_PLAN.md) | Development phases |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.7+
- Dart SDK 3.0+
- Android Studio / VS Code

### Installation

```bash
# Clone repository
git clone https://github.com/user/motivaid.git
cd motivaid

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 👥 User Roles

| Role | Description |
|------|-------------|
| **Midwife** | Primary user - clinical & training access |
| **Supervisor** | Facility oversight & reports |
| **Admin** | System management |

## 🔑 Key Features

### Clinical Mode
- ✅ Maternal risk assessment
- ✅ E-MOTIVE step-by-step checklist
- ✅ Shock index calculation
- ✅ Blood loss monitoring
- ✅ Emergency escalation
- ✅ Automatic documentation

### Training Mode
- ✅ Simulated PPH scenarios
- ✅ Interactive quizzes
- ✅ Performance tracking

### Offline Support
- ✅ Full offline functionality
- ✅ Automatic sync when online
- ✅ Conflict resolution

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

See [DEVELOPMENT_GUIDELINES.md](docs/DEVELOPMENT_GUIDELINES.md) for contribution guidelines.
