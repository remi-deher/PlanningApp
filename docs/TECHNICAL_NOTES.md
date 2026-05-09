# Documentation Technique — PlanningApp iOS

> Généré par IA (Antigravity / Claude Sonnet 4.6) — Mai 2026  
> À destination des agents IA ou développeurs reprenant ce projet.

---

## 1. Vue d'ensemble du projet

**PlanningApp** est une application iOS de gestion de planning d'équipes.  
Elle est construite entièrement en **SwiftUI** et utilise **XcodeGen** pour générer le fichier `.xcodeproj` à partir d'un fichier `project.yml` déclaratif.

La CI/CD est gérée par **GitHub Actions** (`.github/workflows/build.yml`) qui :
1. Installe XcodeGen via Homebrew
2. Génère le `.xcodeproj` avec `xcodegen generate`
3. Compile avec `xcodebuild` sans signature de code (`CODE_SIGNING_ALLOWED=NO`)
4. Package le `.app` en `.ipa` (archive ZIP avec structure `Payload/`)
5. Upload l'artefact `PlanningApp-Unsigned.zip`

L'IPA produit est **non signé** et doit être installé via **AltStore** ou **TrollStore**.

---

## 2. Configuration du projet (`project.yml`)

```yaml
name: PlanningApp
options:
  bundleIdPrefix: com.remi2.planning   # Préfixe unique pour éviter les erreurs Apple ID
targets:
  PlanningApp:
    type: application
    platform: iOS
    deploymentTarget: "18.0"           # iOS 18 requis pour Tab {} et .sidebarAdaptable
    sources:
      - path: PlanningApp              # Dossier source principal
    info:
      path: PlanningApp/Info.plist     # Référence explicite au fichier Info.plist
    settings:
      CODE_SIGNING_REQUIRED: NO
      CODE_SIGN_IDENTITY: ""
      PROVISIONING_PROFILE_SPECIFIER: ""
      DEVELOPMENT_TEAM: ""
```

**Points critiques :**
- `bundleIdPrefix: com.remi2.planning` — Le préfixe `com.demo` causait des erreurs HTTP 200 HTML depuis les serveurs Apple lors de l'installation via AltStore.
- `deploymentTarget: "18.0"` — Obligatoire pour `Tab {}` et `.sidebarAdaptable` (iOS 18+).
- `info: path:` — XcodeGen exige que ce soit une référence à un fichier **existant dans le repo**. La syntaxe `info: dict:` ou `info: properties:` n'est **pas supportée** dans la version installée par Homebrew sur le runner GitHub Actions et provoque `Parsing project spec failed: Decoding failed at "path": Nothing found`.

---

## 3. `Info.plist` — Configuration critique

Fichier : `PlanningApp/Info.plist`

```xml
<key>UILaunchScreen</key>
<dict/>
```
→ Déclaration du Launch Screen vide. Sans cette clé, iOS affiche un avertissement et peut lancer l'app en mode compatibilité (résolution incorrecte sur iPhone 14/15/16 Pro Max).

```xml
<key>UIRequiresFullScreen</key>
<true/>
```
→ **Clé critique pour l'affichage plein écran natif.** Sans cette clé, iOS peut scaler l'app pour les anciens appareils, ce qui donne une interface mal proportionnée (marges trop grandes, éléments flottants) sur les grands écrans comme l'iPhone 16 Pro Max.

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
</dict>
```
→ Désactive le support multi-fenêtres (nécessaire pour SwiftUI pur sans SceneDelegate).

---

## 4. Architecture SwiftUI — Migrations iOS 18+

### 4.1 `@Observable` macro (iOS 17+)

**Fichier :** `PlanningApp/Models/AppData.swift`

```swift
// AVANT (iOS 14+)
class AppData: ObservableObject {
    @Published var teams: [Team] = []
    @Published var collaborators: [Collaborator] = []
}

// APRÈS (iOS 17+)
import Observation

@Observable
class AppData {
    var teams: [Team] = []
    var collaborators: [Collaborator] = []
}
```

**Impact :** Le macro `@Observable` (module `Observation`) remplace `ObservableObject` + `@Published`. Le tracking de dépendances est automatique et granulaire : SwiftUI ne re-render que les vues qui accèdent effectivement à la propriété modifiée.

### 4.2 Injection de dépendance — `.environment()` (iOS 17+)

**Fichier :** `PlanningApp/PlanningAppApp.swift`

```swift
// AVANT
@StateObject private var appData = AppData()
ContentView().environmentObject(appData)

// APRÈS
@State private var appData = AppData()   // @State, pas @StateObject
ContentView().environment(appData)       // .environment(), pas .environmentObject()
```

**Fichiers affectés (toutes les vues) :**
```swift
// AVANT
@EnvironmentObject var appData: AppData

// APRÈS
@Environment(AppData.self) private var appData
```

> ⚠️ Les deux systèmes (`ObservableObject`/`@EnvironmentObject` ET `@Observable`/`@Environment`) ne sont **pas compatibles entre eux**. Tout le projet doit utiliser l'un ou l'autre de manière cohérente.

### 4.3 `TabView` avec `Tab {}` et `.sidebarAdaptable` (iOS 18+)

**Fichier :** `PlanningApp/ContentView.swift`

```swift
// AVANT (iOS 14+)
TabView {
    NavigationStack { DashboardView() }
        .tabItem { Label("Bord", systemImage: "square.grid.2x2.fill") }
}

// APRÈS (iOS 18+)
TabView {
    Tab("Bord", systemImage: "square.grid.2x2.fill") {
        NavigationStack { DashboardView() }
    }
    // ...
}
.tabViewStyle(.sidebarAdaptable)   // iOS 18+ : sidebar sur iPad, tab bar sur iPhone
```

**Prérequis :** `deploymentTarget >= 18.0` dans `project.yml`. Si la cible est < 18.0, le compilateur émet `error: 'Tab' is only available in iOS 18.0 or newer`.

### 4.4 `NavigationStack` vs `NavigationView`

`NavigationView` est **déprécié depuis iOS 16**. Toutes les vues utilisent désormais `NavigationStack`.

```swift
// DÉPRÉCIÉ
NavigationView { ... }

// ACTUEL
NavigationStack { ... }
```

### 4.5 `ContentUnavailableView` (iOS 17+)

Utilisé dans `ScheduleView`, `MessagesListView`, `TeamListView`, `DashboardView` pour les états vides :

```swift
// État vide générique
ContentUnavailableView(
    "Aucun shift prévu",
    systemImage: "calendar.badge.plus",
    description: Text("Ajoutez des shifts depuis les paramètres.")
)

// État vide pour recherche
ContentUnavailableView.search(text: searchText)
```

### 4.6 `#Preview` macro (iOS 17+)

Remplace `PreviewProvider` dans toutes les vues :

```swift
// AVANT
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView().environmentObject(AppData())
    }
}

// APRÈS
#Preview {
    NavigationStack { DashboardView() }
        .environment(AppData())
}
```

### 4.7 `LabeledContent` et `Section` avec string (iOS 16+)

**Fichier :** `SettingsView.swift`

```swift
// AVANT
Section(header: Text("Application")) {
    HStack { Text("Version"); Spacer(); Text("1.0.0").foregroundColor(.secondary) }
}

// APRÈS
Section("Application") {               // String directe, pas Text()
    LabeledContent("Version", value: "1.0.0")
}
```

---

## 5. Composants UI custom

### `RoundedCorner` (dans `ChatView.swift`)

Shape personnalisée pour arrondir des coins **spécifiques** d'une vue (style bulles iMessage) :

```swift
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Utilisation : coins arrondis côté droit pour l'expéditeur
.clipShape(RoundedRectangle(cornerRadius: 18, corners: [.topLeft, .topRight, .bottomLeft]))
```

### `StatCard` — Cartes de statistiques avec gradient

```swift
struct StatCard: View {
    let gradient: LinearGradient  // Gradient passé en paramètre pour la flexibilité

    var body: some View {
        VStack { ... }
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
```

### Graphique avec `Charts` framework (iOS 16+)

**Fichier :** `DashboardView.swift`

```swift
import Charts

Chart {
    ForEach(getRoleData(), id: \.role) { item in
        BarMark(
            x: .value("Rôle", item.role),
            y: .value("Nombre", item.count)
        )
        .foregroundStyle(by: .value("Rôle", item.role))
        .cornerRadius(5)
    }
}
```

---

## 6. Modèles de données

Tous dans `PlanningApp/Models/` :

| Fichier | Description |
|---|---|
| `AppData.swift` | Source de vérité unique (`@Observable`), injecté via `.environment()` |
| `Team.swift` | Équipe avec `name`, `colorHex`, `icon` |
| `Collaborator.swift` | Membre avec `firstName`, `lastName`, `role`, `teamId?` |
| `Schedule.swift` | Créneau avec `collaboratorId`, `startTime`, `endTime`, `notes?` |
| `Message.swift` | Message avec `senderId`, `receiverId?`, `teamId?`, `content`, `timestamp` |

**Architecture de messagerie :**
- Message **privé** : `senderId` + `receiverId` (les deux sont des `UUID` de `Collaborator`)
- Message **d'équipe** : `senderId` + `teamId` (les deux sont des `UUID`)

---

## 7. CI/CD — `.github/workflows/build.yml`

```yaml
- name: Build App
  run: |
    xcodebuild -project PlanningApp.xcodeproj \
               -scheme PlanningApp \
               -configuration Release \
               -sdk iphoneos \
               clean build \
               SYMROOT=build \                     # Force la sortie dans ./build/
               INFOPLIST_FILE=PlanningApp/Info.plist \  # Force l'utilisation de notre Info.plist
               CODE_SIGNING_ALLOWED=NO \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGN_IDENTITY=""
```

**Points critiques :**
- `SYMROOT=build` : Sans cela, Xcode place les artifacts dans `~/Library/Developer/Xcode/DerivedData/` et l'étape de packaging ne peut pas les trouver.
- `INFOPLIST_FILE=PlanningApp/Info.plist` : Force Xcode à utiliser notre `Info.plist` plutôt que d'en générer un automatiquement, ce qui garantit la présence de `UIRequiresFullScreen`.
- Le build produit `build/Release-iphoneos/PlanningApp.app`

**Packaging en IPA :**
```bash
mkdir -p build/Payload
cp -r build/Release-iphoneos/PlanningApp.app build/Payload/
cd build
zip -r PlanningApp.ipa Payload   # Un IPA est simplement un ZIP avec structure Payload/
```

---

## 8. Erreurs connues et solutions

| Erreur | Cause | Solution |
|---|---|---|
| `Decoding failed at "path": Nothing found` | Syntaxe `info: dict:` ou `info: properties:` non supportée par XcodeGen | Utiliser `info: path: PlanningApp/Info.plist` avec un fichier existant |
| `'Tab' is only available in iOS 18.0 or newer` | `deploymentTarget: "17.0"` dans `project.yml` | Passer à `deploymentTarget: "18.0"` |
| `Encountered unknown tag html on line 1` (AltStore) | Bundle ID `com.demo.*` rejeté par Apple → réponse HTML | Changer le `bundleIdPrefix` en `com.remi2.planning` |
| Interface non plein écran sur iPhone 16 Pro Max | `UIRequiresFullScreen` absent de `Info.plist` | Ajouter `<key>UIRequiresFullScreen</key><true/>` |
| `cp: build/Release-iphoneos/PlanningApp.app: No such file or directory` | Xcode place les artifacts dans DerivedData | Ajouter `SYMROOT=build` à la commande `xcodebuild` |
