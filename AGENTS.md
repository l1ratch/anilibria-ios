# AGENTS.md — AniLiberty iOS (Anilibria) Engineering Guidelines & Context

## 1. Project Overview & Rules of Engagement

- **App Name (Display)**: `AniLiberty` (`CFBundleDisplayName = AniLiberty`)
- **Internal Swift Module Name**: `Anilibria` (`PRODUCT_MODULE_NAME = Anilibria`)
  - *CRITICAL*: Never rename the internal module name in `project.pbxproj` or Swift files. All 47 XIB files reference `customModule="Anilibria"`. Changing this causes runtime `NSUnknownKeyException` crashes on launch.
- **Target OS**: iOS 16.0+ (`IPHONEOS_DEPLOYMENT_TARGET = 16.0`)
- **Target Device Optimization**: **iPhone 12 mini** (Compact screen width: 375pt, OLED, Safe Area, Home Indicator).
- **Architecture**: **VIPER + DI (DITranquillity) + Combine + XIB / UIKit**
- **Strict Rule on Business Logic**: **ZERO modifications to business logic** (`Presenter` business rules, `ServiceLayer`, `DataLayer`, `Repositories`, `Combine` pipelines, API contracts).

---

## 2. Architecture & Layer Boundaries

```
Anilibria/
├── Classes/
│   ├── ApplicationLayer/
│   │   ├── AppDelegate/         # AppDelegate, SceneDelegate, App lifecycle
│   │   ├── Dependencies/        # AppFramework (DI registration), DependenciesConfiguration
│   │   └── MainCoordinator/     # MainAppCoordinator, AppRouter
│   ├── DataLayer/               # CoreData, Repositories, Network, Token/Auth storage
│   ├── ServiceLayer/            # Business services (PlayerService, MenuService, FavoriteService, etc.)
│   └── PresentationLayer/       # Modules (VIPER: View, Presenter, Router, Assembly, Contracts, XIBs)
│       ├── BaseClasses/         # BaseViewController, BaseNavigationController, BaseRouter
│       ├── Common/              # Shared views, Alerts, Shimmers, Loaders
│       └── Modules/             # Feed, Catalog, News, UserCollections, Other, Series, Player, Settings, etc.
└── Resources/
    ├── Assets.xcassets          # AppIcon, colors (surfaces, text, tint, buttons), icons
    ├── Info.plist               # App metadata, UISceneConfigurations, permissions
    └── Theme/                   # AppTheme, InterfaceAppearance, System colors
```

---

## 3. UI/UX Principles: Apple HIG Native Defaults

1. **Native UIKit Controls**:
   - Use standard `UITabBarController` with `UITabBarAppearance` (`UIBlurEffect(style: .systemMaterialDark)`).
   - Use standard `UINavigationController` with `UINavigationBarAppearance` (dynamic scroll edge appearance).
   - Use native **SF Symbols** with standard weights and scales instead of custom raster assets where applicable.
2. **Apple Geometry & Metrics (iPhone 12 mini focus)**:
   - Margins: 16pt standard leading/trailing padding across all lists and cards.
   - Corners: `layer.cornerCurve = .continuous` with 14–16pt radius for cards, 8–10pt for buttons.
   - Materials: `UIBlurEffect` and standard Apple dynamic colors (`.Surfaces.background`, `.Surfaces.content`, `.Surfaces.base`, `.Tint.active`).
3. **No Over-Engineering / No Custom Floating Frames**:
   - Avoid hardcoded screen widths, custom floating containers, or non-standard gesture interceptors. Let UIKit layout hierarchies adapt cleanly to Safe Area.

---

## 4. Build, Packaging & Signing Rules

- **CI/CD**: `.github/workflows/build-ipa.yml` compiles via `xcodebuild` with `CODE_SIGNING_ALLOWED=NO` and packages unsigned `.app` inside `Payload/` -> `AniLiberty.ipa`.
- **Signing Compatibility**: Must produce clean unsigned IPAs compatible with GBox, Sideloadly, AltStore, TrollStore, and Scarlet (no `--deep` ad-hoc signature corruption).
- **Info.plist Integrity**:
  - Always preserve `UISceneConfigurations` -> `UISceneDelegateClassName = $(PRODUCT_MODULE_NAME).SceneDelegate`.
  - Always set `UIRequiredDeviceCapabilities` to `arm64`.
  - Disable Mac Catalyst (`SUPPORTS_MACCATALYST = NO`) in build configurations.
