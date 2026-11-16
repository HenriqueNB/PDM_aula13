# Aula 15 — Câmera e Galeria de Mídia com Flutter

Aplicativo Flutter de perfil de usuário com captura de foto pela câmera, seleção
na galeria e persistência do caminho da imagem, desenvolvido a partir do roteiro
da Aula 15.

## Funcionalidades

- Captura de foto com a câmera nativa (`ImageSource.camera`).
- Seleção de imagem na galeria (`ImageSource.gallery`).
- Compressão leve no momento da escolha (`imageQuality: 85`, `maxWidth: 1080`).
- Exibição em `CircleAvatar` com `FileImage` e avatar padrão (`Icons.person`).
- Modal (`showModalBottomSheet`) para escolher a origem da mídia.
- Estado de carregamento e tratamento de erros ao acessar câmera/galeria.
- **Desafio básico:** opção “Remover Foto” no modal, voltando ao avatar padrão.
- **Desafio intermediário:** toque na foto abre a visualização em tela cheia com
  animação `Hero` e zoom por gesto de pinça (`InteractiveViewer`).
- **Desafio avançado:** caminho da foto e nome do perfil persistidos com
  `SharedPreferences`, restaurados ao reabrir o app.

## Estrutura

```text
lib/
├── screens/
│   ├── perfil_screen.dart           # Perfil, modal e avatar
│   ├── foto_visualizacao_screen.dart # Tela cheia com Hero + zoom
│   ├── geolocalizacao_screen.dart    # Aula 14 (preservada)
│   └── tarefas_screen.dart           # Aula 13 (preservada)
├── services/
│   ├── media_service.dart            # image_picker (câmera e galeria)
│   ├── perfil_service.dart           # Persistência de nome e caminho da foto
│   ├── location_service.dart         # Aula 14 (preservada)
│   └── preferences_service.dart      # Aula 12 (preservada)
├── utils/
│   └── geo_utils.dart                # Aula 14 (preservada)
└── main.dart                         # Entrada do app (Aula 15)
```

## Dependências

```yaml
dependencies:
  image_picker: ^1.1.0 # Câmera e galeria de fotos
  shared_preferences: 2.2.2 # Persistência do caminho da foto
```

## Permissões

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission
    android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

O `image_picker` solicita a permissão de câmera em tempo de execução quando ela
está declarada no manifesto. No Android 13+ a galeria usa o Photo Picker do
sistema, que não exige permissão de armazenamento.

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Permite tirar uma foto para usar como imagem de perfil.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Permite escolher uma foto da galeria para usar como imagem de perfil.</string>
```

## Como executar

```bash
flutter pub get
flutter run
```

> A câmera deve ser testada em dispositivo físico ou emulador Android com câmera
> virtual configurada. Para popular a galeria do emulador:
> `adb push foto.jpg /sdcard/Pictures/` seguido de um novo scan de mídia.

## Testes

```bash
flutter analyze
flutter test
```

Os testes cobrem a persistência de nome/caminho da foto, o estado inicial da
tela de perfil e as opções exibidas no modal de mídia.

## Versionamento sugerido

```bash
git add pubspec.yaml android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist lib/services/media_service.dart
git commit -m "feat: adiciona image_picker e permissoes de camera e galeria"

git add lib/services/perfil_service.dart lib/screens/perfil_screen.dart lib/screens/foto_visualizacao_screen.dart lib/main.dart test/
git commit -m "feat: implementa captura de foto de perfil com image_picker"

git push
```
