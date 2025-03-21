//
//  AppDelegate.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//
// 기존 임포트
import UIKit
import FirebaseCore
// 에뮬레이터 사용을 위한 추가 임포트
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure() // 파이어베이스 초기화
        
        //MARK: - 에율레이터 사용 설명서
        // * 1~14번까지는 최초 1회만 설정
        // 1.  터미널 시작: 프로젝트 폴더 경로에서 터미널을 시작한다.
        // 2.  firebase-cli 설치: < brew install firebase-cli > <-- <> 안의 명령어로 firebase-cli를 설치해준다. (설치돼있다면 생략)
        // 3.  firebase 로그인: < firebase login > <- 이 명령어로 firebase 로그인을 해준다.
        // 4.  firebase 프로젝트 연결 시작: < firebase init > <- 프로젝트 루트 디렉터리에서 firebase 프로젝트 연결을 시작한다.
        // 5.  [Question] ? Which Firebase features do you want to set up for this directory? Press Space to select features, then Enter to confirm your choices.
        //     [Answer] SpaceBar로 선택: Firestore, Storage, emulators, remote config 4개 선택 후 Enter
        // 6.  프로젝트 선택: 프로젝트의 이름(SomethingDelicious) 선택 후 Enter
        // * 7~11번 기본설정들은 전부 Enter키를 누르거나 y를 입력한다.
        // 7.  [Question] ? What file should be used for Firestore Rules? (firestore.rules)
        //     [Answer] Enter키
        // 8.  [Question] ? File firestore.rules already exists. Do you want to overwrite it with the Firestore Rules from the Firebase Console? (y/N)
        //     [Answer] y
        // 9.  [Question] ? What file should be used for Firestore indexes? (firestore.indexes.json)
        //     [Answer] Enter키
        // 10. [Question] ? File firestore.indexes.json already exists. Do you want to overwrite it with the Firestore Indexes from the Firebase Console? (y/N)
        //     [Answer] y
        // 11. [Question] ? What file should be used for Storage Rules? (storage.rules)
        //     [Answer] Enter키
        // 12. Emulator 설정: [Question] ? Which Firebase emulators do you want to set up? Press Space to select emulators, then Enter to confirm your choices.
        //.    [Answer] SpaceBar로 선택: Authentication Emulator, Firestore Emulator, Database Emulator, (Storage Emulator) 선택 후 Enter
        // 13. 포트 설정은 Enter키를 눌러서 기본으로 설정: Authentication(9099), Firestore(8080), Database(9000), Storage(9199)
        // 14. Emulator 다운: y를 입력해서 바로 설치
        // (15). [이미 작성됨] .gitignore에 Emulator 관련 파일 추가
        
        // * Emulator가 설치됐으면 이후로는 16~19번만 진행.
        // 16. 에뮬레이터 코드 섹션을 선택하고 CMD+/를 눌러 주석을 해제한다.
        // 17. 프로젝트 루트 디렉토리에서 터미널을 시작한다.
        // 18. *종료시 데이터 초기화되는 에뮬레이터 명령어* ->  firebase emulators:start
        // 18. *데이터 유지되는 에뮬레이터 명령어* ->         firebase emulators:start --import emulator-backup  --export-on-exit
        // 19. 터미널에서 Ctrl + C를 눌러 에뮬레이터를 종료한다.
        
        // * Firebase 서버 이용시, 에뮬레이터 섹션 다시 주석 처리 (Divider 사이만)
        
        
        //MARK: - 에뮬레이터 섹션 시작
        // 앱의 시작 지점에서 에뮬레이터 설정
        #if DEBUG
        // 디버그 모드(개발 중)일 때만 실행되는 코드
        // 1. Firestore 설정
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"          // 로컬 에뮬레이터 사용
        settings.isSSLEnabled = false             // 개발용 보안 설정 해제
        // 개발 중에도 캐싱이 필요하다면 아래 라인은 주석 처리
        // settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings // 설정 적용 필요
        
        // 2. 각 서비스의 에뮬레이터 설정
        // let auth = Auth.auth()
        Auth.auth().useEmulator(withHost: "localhost", port: 9099) // Authentication 에뮬레이터, 직접 적용됨
        // let storage = Storage.storage()
        Storage.storage().useEmulator(withHost: "localhost", port: 9199) // Storage 에뮬레이터, 직접 적용됨
        #endif
        //MARK: - 에뮬레이터 섹션 끝
        
        return true
    }
}
