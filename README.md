![Image](https://github.com/user-attachments/assets/bb015c42-988b-46b5-a8d7-b20a23f89e36)
  
# 소개
바나나 무한 불판 매크로는 포켓몬 카드 게임 Pocket의 무한 불판 매크로입니다.  
이미지 맥스의 유료화 정책에 반대하여 오픈소스 기반으로 만들어졌습니다.  
무료 오픈소스 프로그램인 AutoHotkey를 사용합니다.  

# 최신 버전 다운로드
[**다운로드 (v2.03)**](https://github.com/banana-juseyo/Banana-Macro-PtcgP/archive/refs/heads/main.zip)  
  
# 설치
1. AutoHotkey v2 최신 버전을 설치  
[**다운로드**](https://www.autohotkey.com/download/ahk-v2.exe)  
  
2. 바나나 매크로를 다운로드 & 원하는 곳에 압축 풀기  
[**다운로드**](https://github.com/banana-juseyo/Banana-Macro-PtcgP/archive/refs/heads/main.zip)  
  
3. MuMu Player 12를 설치  
[**다운로드**](https://adl.easebar.com/d/g/mumu/c/mumuglobal?type=pc&direct=1)  
  
4.  MuMu Player 12에 포켓몬 카드 게임 Pocket *2배속 앱* 또는 *3배속 앱*설치  
(파일은 각자 구할 것)  


# 실행하기
1. **(필수)** MuMu Player 인스턴스 설정을 다음에 맞춘다  
     -ㅤ해상도 : 540 x 1260  
     -ㅤDPI : 220  
  
2. MuMu Player에서 불판 계정으로 로그인 & 홈 화면까지 진입  
  
3. 바나나 매크로 폴더에서 Banana.ahk 파일을 실행  
  
4. '설정' 버튼을 눌러 인스턴스 이름 입력 / 해상도 설정  
  
5. 원하는 버튼을 눌러 매크로 시작  
     -ㅤ"시작" 버튼 : 친추 수락부터 진행  
     -ㅤ"친구 삭제부터 시작" 버튼 : 친구창 먼저 비우고 → 친추 수락 진행  
  
# 장점  
![Banana v1 00 presentation](https://github.com/user-attachments/assets/e45086e5-18a1-4ace-a460-1fe25f392436)  
   
1. 여권 검사 및 친추 수락 속도가 빠름  
(기존 2배 이상 속도 / 약 4초에 1번 / 10분에 평균 90~100명 수락)  
2. 찐빠가 잘 안남  
3. 인터페이스가 맛도리
4. 다양한 지원폭 (해상도, 앱 종류)
     
# 유의사항
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
 - [x] 개판인 코드 수정
 - [x] 여권 심사 속도 최적화 2
 - [ ] 아래에서부터 불판 갈기
 - [ ] 블랙리스트 & 블랙리스트 DB
(여권 미소지 & 전굽러 불이익)
 - [ ] 심사 조건 추가 설정
(엠블럼, 여권 카드 변경 등)
 - [x] 다중 해상도 지원
 - [ ] 폰으로 원격 가동
  
# Credit
- 여권 무불 개념을 제안하고 매크로 제작한 포갤 파딱 "ㅇㅇ"  
https://gall.dcinside.com/m/pokemontcgpocket/263730  
- "thqby" for WebView2 control in ahk  
https://github.com/thqby/ahk2_lib  
- "TheArkive" for JXON_ahk2  
https://github.com/TheArkive/JXON_ahk2  
- "iseahound" for ImagePut  
https://github.com/iseahound/ImagePut  
  
# 수정 & 재배포
- GPL-3.0 하에 자유롭게 수정 재배포 가능
- 재배포 시 괜찮다면 제작자의 Credit과 본 Repo 주소를 남겨주면 좋겠음  
(banana-juseyo https://github.com/banana-juseyo/Banana-Macro-PtcgP)  
  
# FAQ  
- **Q: 1920*1080 아닌 다른 해상도에서도 돌아감?**  
A: 해상도(배율)의 순으로, FHD(100%), FHD(125%), QHD(150%), 4K(200%)를 지원함.
설정화면에서 맞는 해상도로 설정하면 됨.
  
- **Q: 멀티 인스턴스 됨?**  
A: 정식으로 테스트한 것은 아니지만 폴더를 여러개 복사해서 실행하면 가능.  
써본 사람들 말로는 약간씩 원활하지 않은 부분이 있지만 꽤 괜찮다고 함.  
멀티 인스턴스 지원도 추후 업데이트 예정.  
  
- **Q: Error while update라고 뜨면서 실행이 안됨**  
A: 자동 업데이트 중에 꼬인 것임. 매크로 파일 새로 받아주기 바람.  

- **Q: 오토핫키 깔려있는데 banana.ahk 파일이 실행이 안됨**  
A: 아마도 레어팩 매크로에 쓰이는 v1이 깔려있을 건데, v2를 깔아야 함.
오토핫키는 v1과 v2가 호환이 안됨.
v1 v2 컴에 둘다 깔아놓으면 시작할때 뭘로 실행할지 물어볼것임.  
  
- **Q: 단축키 못바꿈?**  
A: 메모장으로 직접 바꾸면 됨.  
banana.ahk 열어서 F5::, ^R:: (= Ctrl+R) 등 검색해서 F9::, ^Y::등 원하는 키로 바꾸면 됨.  
단축키를 아예 지우면 에러나니까 안쓰고 싶으면 F13:: ~ F24::로 변경하는거 추천.  
(단축키 설정 기능은 추가 예정)  
  
