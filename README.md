# Aula 14 — Geolocalização e GPS com Flutter

Aplicativo Flutter de check-in com captura de coordenadas, rastreamento contínuo
e integração com o Google Maps, desenvolvido a partir do roteiro da Aula 14.

## Funcionalidades

- Captura única de latitude, longitude, precisão e altitude com `getCurrentPosition`.
- Rastreamento contínuo com `getPositionStream`.
- Verificação de GPS ativo e solicitação de permissões nativas.
- Tratamento de permissões negadas e negadas permanentemente.
- **Desafio básico:** chip de precisão (verde, amarelo ou vermelho).
- **Desafio intermediário:** distância até a Fatec Matão com `distanceBetween`.
- **Desafio avançado:** botão para abrir a posição no Google Maps com `url_launcher`.
- Indicador visual de rastreamento ativo no AppBar.

## Estrutura

```text
lib/
├── screens/
│   ├── geolocalizacao_screen.dart  # Interface de check-in e GPS
│   └── tarefas_screen.dart         # Tela da Aula 13 (preservada)
├── services/
│   ├── location_service.dart       # Permissões e acesso ao GPS
│   └── preferences_service.dart    # Aula 12 (preservada)
├── utils/
│   └── geo_utils.dart              # Precisão, distância e formatação
└── main.dart                       # Entrada do app (Aula 14)
```

## Permissões

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Permite exibir sua localização atual e calcular a distância até a Fatec Matão.</string>
```

## Como executar

```bash
flutter pub get
flutter run
```

> O GPS deve ser testado em um dispositivo físico ou emulador Android com
> localização configurada. Em emuladores, use `adb emu geo fix <longitude> <latitude>`.

## Testes

```bash
flutter analyze
flutter test
```

Os testes cobrem a classificação de precisão, a formatação de distância e o
estado inicial da tela de geolocalização.

## Versionamento sugerido

```bash
git add android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist pubspec.yaml lib/services/location_service.dart lib/utils/geo_utils.dart
git commit -m "feat: configura permissoes de GPS e servico LocationService"
git add lib/screens/geolocalizacao_screen.dart lib/main.dart test/
git commit -m "feat: constroi interface de check-in com coordenadas e rastreamento em tempo real"
git push
```
