# iOS testen zonder Mac

Je kunt de Benokee-app voor iOS laten bouwen en testen **zonder zelf een Mac te hebben**, door een cloud-Mac (GitHub Actions of Codemagic) te gebruiken.

---

## 1. Controleren dat de iOS-build slaagt (CI)

De repository bevat een GitHub Actions-workflow die op een **macOS-runner** de app voor iOS (simulator) bouwt. Zo zie je of de code voor iOS compileert.

### Gebruik

1. **Code op GitHub zetten**  
   Push je project naar GitHub (bijv. alleen de map `benokee_app` als eigen repo, of je hele workspace).

2. **Workflow-locatie**
   - Als je **alleen de map `benokee_app`** als Git-repo gebruikt: de workflow staat in `benokee_app/.github/workflows/build-ios.yml` en wordt automatisch gebruikt.
   - Als je **de bovenliggende map** (bijv. `cursor`) als repo gebruikt: kopieer de workflow naar de root van je repo:
     - Maak aan: `<repo-root>/.github/workflows/build-ios.yml`
     - Voeg bovenaan onder `jobs.build-ios` toe:  
       `defaults: run: working-directory: benokee_app`

3. **Workflow laten draaien**
   - Bij elke push op `main` of `master` (en bij pull requests).
   - Of handmatig: tab **Actions** → workflow **"iOS build"** → **Run workflow**.

4. **Resultaat**
   - Groen: iOS-build (simulator) is geslaagd.
   - Rood: bekijk de logs in de Actions-run; daarmee kun je iOS-buildfouten oplossen.

Deze build gebruikt **geen** code signing en **geen** Apple-account. Hij controleert alleen of de app voor iOS (simulator) bouwt.

---

## 2. App op een echte iPhone testen

Om de app op je eigen iPhone te zetten heb je een **Apple Developer-account** (€99/jaar) nodig, plus één van onderstaande routes.

### Optie A: Codemagic (aanrader als je geen Mac hebt)

[Codemagic](https://codemagic.io) biedt een gratis laag en ondersteunt Flutter + iOS goed. Geen Mac nodig.

1. Account aanmaken op [codemagic.io](https://codemagic.io) (bijv. met GitHub).
2. Nieuwe app toevoegen en je Git-repo koppelen (map met `benokee_app` of pad naar Flutter-project instellen).
3. **iOS** inschakelen en in het Codemagic-dashboard je **Apple ID** en eventueel **App Store Connect API key** of **signing certificates** instellen (stappen staan in hun wizard).
4. Build starten; Codemagic bouwt de IPA en kan deze naar **TestFlight** uploaden.
5. In **TestFlight** (App Store Connect) testers toevoegen; je installeert de app op je iPhone via TestFlight.

Documentatie: [Codemagic – Flutter iOS](https://docs.codemagic.io/flutter-publishing/publishing-to-app-store-connect/).

### Optie B: GitHub Actions + TestFlight

Je kunt ook met GitHub Actions een **IPA** bouwen en naar TestFlight uploaden. Dat vereist:

- Apple Developer-account.
- **Signing certificate** (`.p12`) en **provisioning profile** (bijv. eenmalig op een geleende Mac of via [fastlane match](https://docs.fastlane.tools/actions/match/)).
- Deze als **secrets** in GitHub zetten (base64-gecodeerd certificate + profile, wachtwoord, enz.).

Er zijn voorbeelden en actions te vinden (zoek op “Flutter iOS IPA GitHub Actions”). Het is meer werk dan Codemagic als je nog nooit code signing hebt gedaan.

### Optie C: Eenmalig een Mac gebruiken

- **Mac lenen/huren** (bijv. vriend, bibliotheek, cloud-Mac): Xcode installeren, Apple ID in Xcode, project openen in `ios/`, dan **Product → Archive** en upload naar App Store Connect → TestFlight.
- **Apple Developer Program** blijft nodig voor TestFlight en voor installatie op echte toestellen.

---

## Samenvatting

| Wat je wilt                         | Wat je doet                                                |
|------------------------------------|------------------------------------------------------------|
| Controleren of iOS-build lukt       | GitHub Actions gebruiken (workflow `build-ios.yml`)       |
| App op je iPhone installeren       | Codemagic + TestFlight, of GitHub Actions + signing, of Mac + Xcode |

Als je alleen wilt **verifiëren dat de app voor iOS bouwt**, is de bestaande GitHub Actions-workflow voldoende. Voor **echte iPhones** is Codemagic + TestFlight de meest eenvoudige route zonder eigen Mac.
