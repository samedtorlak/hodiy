# Hodiy

Hodiy, Orta Asya için çevrimdışı çalışan namaz vakitleri, kıble, zikirmatik ve hicri takvim uygulamasıdır. Arayüz İngilizce şablon dilinin yanında Özbekçe (`uz`), Kazakça (`kk`), Kırgızca (`ky`), Tacikçe (`tg`) ve Rusça (`ru`) sunulur.

## Mimari

- `lib/core/`: Uygulama genelinde paylaşılan konum (`location`), kalıcı depolama (`storage`), reklam (`ads`), yerelleştirme (`localization`) ve gezinme (`navigation`) altyapısını içerir.
- `lib/features/`: `prayer_times`, `qibla`, `tasbih`, `hijri`, `notifications` ve `settings` özelliklerini birbirinden ayırır. Feature modülleri `domain/`, `state/` ve `ui/` sorumluluklarına göre düzenlenir; yalnızca ihtiyaç duyulan katmanlar repoda oluşturulmuştur.

## Geliştirme ortamı

Bu repo, `aarch64` mimarili bir sunucuda kaynak koddan kurulan Flutter ile geliştirilmektedir:

```bash
git clone https://github.com/flutter/flutter.git
```

Google'ın hazır Linux Flutter SDK arşivi yalnızca x64 içindir. Buna karşılık Flutter kaynak ağacı ARM64 üzerinde çalıştırıldığında uygun Dart SDK'sını kendisi indirir. Bu nedenle `flutter analyze` ve `flutter test` yerelde çalışır. Android APK veya App Bundle üretmek için ayrıca Android SDK ve Java gerekir; release derlemeleri GitHub Actions'taki `ubuntu-latest` ortamında yapılır.

## Yerel geliştirme

```bash
flutter pub get
flutter analyze --fatal-infos
flutter test
dart format lib test
```

## CI/CD

Repo dört GitHub Actions workflow'u kullanır:

- `.github/workflows/ci.yml`: `main` branch'ine yapılan her push'ta ve her pull request'te format kontrolü, analiz ve test çalıştırır; ardından reklam altyapısı açık bir debug APK üretir.
- `.github/workflows/scaffold.yml`: Flutter Android projesini oluşturmak için kullanılan tek seferlik, elle tetiklenen (`workflow_dispatch`) scaffold akışıdır; görevini tamamlamıştır.
- `.github/workflows/publish.yml`: `main` branch push'larını VE `v*` tag push'larını dinler; gerçek release job'ları yalnızca `if: startsWith(github.ref, 'refs/tags/')` guard'ından geçen tag ref'lerinde çalışıp AAB ve APK üretir, GitHub Release'e ekler. Branch push'ları guard tarafından bilinçli olarak `skipped` gösterilir (tags-only bir push filtresi normal branch pushlarında GitHub tarafından sahte bir `failure` ürettiği için bu desen tercih edildi).
- `.github/workflows/sync-lock.yml`: Elle (`workflow_dispatch`) çalıştırılır; `pubspec.lock` dosyasını günceller ve değişiklik varsa bot hesabıyla repoya gönderir.

## Release secrets

Release imzası için aşağıdaki GitHub Actions secrets değerleri **Settings → Secrets and variables → Actions** bölümüne daha sonra eklenecektir:

- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`

Bu dört değer ayarlanana kadar release build debug anahtarıyla imzalanır. Ortaya çıkan paket cihazda test edilebilir ancak Play Store'a yüklenemez.

Reklam yapılandırması için planlanan secrets değerleri şunlardır:

- `ADMOB_APP_ID`
- `ADMOB_BANNER_ID`

Kimlik sağlanmadığında Android manifest yapılandırması ve banner katmanı Google'ın test reklam kimliklerini kullanır. `ADMOB_APP_ID`, release build'e `ORG_GRADLE_PROJECT_admobAppId` ortam değişkeni olarak (Gradle'ın otomatik `ORG_GRADLE_PROJECT_x` → proje özelliği eşlemesiyle); `ADMOB_BANNER_ID` ise `--dart-define=ADMOB_BANNER_ID=...` ile aktarılır — `.github/workflows/publish.yml`'in "Build release app bundle"/"Build release APK" adımlarına bakın.

## Keystore oluşturma

Release imzası kullanılacağı zaman upload keystore şu komutla üretilebilir:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Oluşan `.jks` dosyasını repoya eklemeyin. Dosyayı tek satırlık Base64 değerine çevirin:

```bash
base64 -w0 upload-keystore.jks
```

Çıktıyı `KEYSTORE_BASE64` secret'ına; komutta belirlediğiniz parola ve alias değerlerini de ilgili diğer secrets alanlarına kaydedin.

## Release süreci

Hedeflenen release akışı şöyledir:

1. GitHub Actions üzerinden `.github/workflows/sync-lock.yml` workflow'unu `workflow_dispatch` ile çalıştırın ve oluşabilecek lockfile commit'ini alın.
2. Sürüm tag'ini oluşturup gönderin:

   ```bash
   git tag vX.Y.Z
   git push --tags
   ```

3. `.github/workflows/publish.yml` otomatik olarak release AAB ve APK dosyalarını üretir ve GitHub Release'e ekler.

## Gizlilik ve GitHub Pages

Landing page ve gizlilik politikası ayrı, public [`samedtorlak/hodiy-site`](https://github.com/samedtorlak/hodiy-site) reposunda tutulur ve <https://samedtorlak.github.io/hodiy-site/> adresinde yayımlanır. Hodiy uygulama reposu private kaldığı ve GitHub Free private repolarda Pages sunmadığı için bu içerikler burada barındırılmaz.

## v1 kapsamı

- Çevrimdışı namaz vakitleri
- Kıble pusulası
- Zikirmatik
- Hicri tarih
- Namaz vakti bildirimleri
- Beş Orta Asya/Rusça yerelleştirmesi ve İngilizce şablon dili (5+1 dil)
- `ADS_ENABLED` Dart define'ı arkasında reklam altyapısı ve test reklam kimliği fallback'i

## v1.1 kuyruğu

- Ana ekran widget'ı
- Ezan sesi; kullanılabilecek lisanslı bir kaynak henüz bulunamadı
- Manyetik sapma düzeltmesi
- Google UMP consent akışı
- Türkmence arayüz
- Özbekçe Kiril arayüz
