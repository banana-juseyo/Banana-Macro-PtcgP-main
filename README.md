# 소개
바나나 무한 불판 매크로는 포켓몬 카드 게임 Pocket의 무한 불판 매크로입니다.  
이미지 맥스의 유료화 정책에 반대하여 오픈소스 기반으로 만들어졌습니다.  
무료 오픈소스 프로그램인 AutoHotkey를 사용합니다.  


# 설치
1. AutoHotkey 최신 버전을 다운로드 & 설치  
[**다운로드**](https://www.autohotkey.com/download/ahk-v2.exe)  
  
2. 바나나 매크로를 다운로드 & 원하는 곳에 압축 풀기  
[**다운로드**](https://github.com/banana-juseyo/Banana-Macro-PtcgP/archive/refs/heads/main.zip)  
  
3. MuMu Player 12를 설치  
[**다운로드**](https://adl.easebar.com/d/g/mumu/c/mumuglobal?type=pc&direct=1)  
  
4.  MuMu Player 12에 포켓몬 카드 게임 Pocket *2배속 앱* 또는 *3배속 앱*설치  
(파일은 각자 구할 것)  


# 실행하기
1. **(필수)** 컴퓨터의 디스플레이 설정을 다음에 맞춘다  
     -ㅤ해상도 : 1920 x 1080  
     -ㅤ배율 (텍스트 크기) : 125%  

2. **(필수)** MuMu Player 인스턴스 설정을 다음에 맞춘다  
     -ㅤ해상도 : 540 x 960  
     -ㅤDPI : 220  
  
3. MuMu Player에서 불판 계정으로 로그인  
& 홈 화면까지 진입  
     3-1. 2배속 앱 사용 시 별도 설정 필요 없음  
     3-2. 3배속 앱 사용 시 앱 내부 설정에서 *2배속*으로 설정  
  
5. 바나나 매크로 폴더에서 Banana.ahk 파일을 실행  
  
6. '설정' 버튼을 눌러 인스턴스 이름 입력  
  
7. 원하는 버튼을 눌러 매크로 시작  
     -ㅤ"시작" 버튼 : 친추 수락부터 진행  
     -ㅤ"친구 삭제부터 시작" 버튼 : 친구창 먼저 비우고 → 친추 수락 진행  
  
# 장점
1. 여권 검사 및 친추 수락 속도가 빠름  
(기존 2배 이상 속도 / 4~5초에 1번 / 10분에 평균 80명 수락)  
2. 찐빠가 잘 안남  
3. 인터페이스가 맛도리  
  
# 유의사항
- 포켓몬 카드 게임 Pocket의 *2배속 앱*을 기준으로 만들어졌기 때문에, *기본 앱*에서는 정상적으로 작동하지 않을 수 있음  
- 자동 업데이트를 지원 : 매크로 실행 시 최신 버전을 확인하고 자동으로 설치  
  
# 개발 로드맵
*(주의 : 개발을 할 수도 있고 안 할 수도 있음)*
 - [x] 여권 심사 & 친구 수락
 - [x] 친구 수락 속도 최적화
 - [x] 친구 삭제 및 자동 사이클
 - [x] 여권 심사 예외처리 로직
 (신청 취소, 마이베스트 미등록 등)
 - [x] 예외 사항 처리
 (불규칙한 로딩 시간, 불규칙한 휠 스크롤 길이 등)
 - [x] GUI 및 환경 설정 구현
 - [x] 자동 업데이트
 - [ ] 개판인 코드 수정
 - [ ] 여권 심사 속도 최적화 2
 - [ ] 아래에서부터 불판 갈기
 - [ ] 블랙리스트 & 블랙리스트 DB
(여권 미소지 & 전굽러 불이익)
 - [ ] 심사 조건 추가 설정
(엠블럼, 여권 카드 변경 등)
 - [ ] 폰으로 원격 가동
  
# Credit
- 여권 무불 개념을 제안하고 매크로 제작한 포갤 파딱 "ㅇㅇ"  
https://gall.dcinside.com/m/pokemontcgpocket/263730  
- "thqby" for WebView2 control in ahk  
https://github.com/thqby/ahk2_lib  
- "TheArkive" for JXON_ahk2  
https://github.com/TheArkive/JXON_ahk2  
  
# 수정 & 재배포
- GPL-3.0 하에 자유롭게 수정 재배포 가능
- 재배포 시 괜찮다면 제작자의 Credit과 본 Repo 주소를 남겨주면 좋겠음  
(banana-juseyo https://github.com/banana-juseyo/Banana-Macro-PtcgP)  
