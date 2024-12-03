# Todo App Flutter

A simple todo app built with Flutter. It is a small DIY project to learn and fun to record todos.

<p align="center"> 
    <img src="https://github.com/user-attachments/assets/33c8279b-9aca-4608-9eee-fb2b3f54cecb" alt="Image 1" width="200" style="margin-right: 20px;"/> 
    <img src="https://github.com/user-attachments/assets/1e6bde8f-0d6b-40ed-ba17-824e3cd4ae63" alt="Image 2" width="200" style="margin-right: 20px;"/> 
    <img src="https://github.com/user-attachments/assets/5dd5d2f0-2716-412b-b67a-0528178cabe2" alt="Image 3" width="200"/> 
</p>

## Features

- Authentication
- Store data in Firebase
- Add, edit, and delete tasks
- Mark tasks as completed
- Add a due date
- Prioritize

## Local Setup

### System Requirements

- **JDK 17**: [Download JDK](https://www.oracle.com/java/technologies/javase-jdk17-downloads.html)
- **Android SDK**: Installed via [Android Studio](https://developer.android.com/studio)
- **Flutter**: [Install Flutter](https://flutter.dev/docs/get-started/install)

### Setup Steps

1. **Clone the repository**:

   ```sh
   git clone https://github.com/tuan4886n/todo_app_flutter.git
   cd todo_app_flutter

   ```

2. **Install dependencies**:

   ```sh
   flutter pub get

   ```

3. **Configure Firebase with FlutterFire**:

   - Go to [Firebase Console](https://firebase.google.com/), and create a new project
   - Follow the instructions to add your Android app to the Firebase project.
   - Follow the instructions to [add Firebase to Flutter app](https://firebase.google.com/docs/flutter/setup?platform=android)
   - Install the FlutterFire CLI:
     ```sh
     flutter pub global activate flutterfire_cli
     ```
   - Run the following command to configure Firebase for your Flutter project:
     ```sh
     flutterfire configure
     ```
   - This command will automatically generate the firebase_options.dart file and update the necessary configurations

4. **Run the application**:
   ```sh
   flutter run
   ```
5. **Build the APK**:
   ```sh
   flutter build apk --release
   ```

### Using Docker

1. **Build the Docker Image**:

   Run the following command to build the Docker image:

   ```sh
   docker build -t my_flutter_app_builder .
   ```

2. **Run the Container to Build APK**:

   Run the following command to build the APK and copy the file to your local machine:

   ```sh
   docker run --rm -v $(pwd)/output:/workspace my_flutter_app_builder
   ```

- **`--rm`**: Automatically remove the container when it exits.
- **`-v $(pwd)/output:/workspace`**: Mount the current directory's `output` folder to the `/workspace` folder inside the container. This allows the built APK to be copied to your local machine.
- You can replace /workspace with any directory path inside the container if needed. (my apk file is in the build/app/outputs/flutter-apk directory)

  ![image](https://github.com/user-attachments/assets/b3453430-103d-4b01-a67f-e79d69c09383)

- **`my_flutter_app_builder`**: The name of the Docker image you built.

### CI/CD with GitHub Actions

This project uses GitHub Actions for continuous integration and deployment. The workflow is defined in `.github/workflows/build.yml`.

**Build APK**: The workflow builds the APK and uploads it as an artifact.

### Conclusion

This README.md includes essential sections like features, local setup, Firebase configuration, using Docker, and CI/CD with GitHub Actions. This will help users easily set up and use your application.

This is just a small personal project for learning and fun purposes!, this is my [apk file](https://drive.google.com/file/d/1ZtEghMNOxj_dX3LLvz5mTwG1X6cPh0pp/view?usp=drive_link) 😊🚀
