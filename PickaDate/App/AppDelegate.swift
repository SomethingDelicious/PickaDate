//
//  AppDelegate.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import UIKit

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
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
        
//        #else
//        // 프로덕션 환경 설정, 릴리즈 모드(실제 배포)일 때만 실행되는 코드
//        let settings = Firestore.firestore().settings
//        settings.isPersistenceEnabled = true      // 실제 환경에서 캐싱 활성화
//        settings.cacheSizeBytes = FirestoreCacheSizeBytes.MB_100  // 캐시 크기 설정 (기본값: 40MB)
//        Firestore.firestore().settings = settings // 설정 적용 필요
        #endif
        
        return true
    }
}
