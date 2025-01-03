# <img width="30" alt="dokki_logo" src="https://github.com/user-attachments/assets/1404bfb0-c99a-4b28-8b96-eba10d68be4d" /> 다독

## 📲 프로젝트 소개

(다)이어리로 만드는 (독)서 습관

다독으로 다독하자

지친 일상을 다독이다

독서가 어려운 현대인을 위한 독서 다이어리! 다독과 함께 독서 습관 만들기

**앱 다운로드 링크** >> [Link](https://drive.google.com/file/d/1DsdmeJusxr9iOYUP0DWRHnZjN4xHRwX8/view?usp=sharing)


## 🗓️ 개발 기간

- 2024.12.26 ~ 2025.01.02

## 👥 Team Members (팀원 및 팀 소개)

|                                                      👩🏻‍💻 이한샘                                                       |                                                      🥔 고상혁                                                       |
| :------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------: |
| <img src="https://github.com/user-attachments/assets/bb17ef51-ebab-4d13-ad63-1e4bd8fd25ad" alt="이한샘" width="150"> | <img src="https://github.com/user-attachments/assets/9f830237-7f05-41ff-b56f-ae6cb546f4bf" alt="고상혁" width="150"> |
|                                                   기획 / Tab2 개발                                                   |                                                 기획 / Tab1,3,4 개발                                                 |
|                                                     KAIST AE/CS                                                      |                                                    KOREA UNIV. CS                                                    |
|                                                ihansaem1@kaist.ac.kr                                                 |                                                 90sangko@korea.ac.kr                                                 |
|                                          [GitHub](https://github.com/damhs)                                          |                                       [GitHub](https://github.com/sanghyuk-ko)                                       |

## 💻 개발환경 및 기술스택

- 프로그래밍 언어 : **Dart**
- 플랫폼 : **Flutter**
- IDE : **AndroidStudio**
- 디자인 : **Figma**
- 협업 : **Github**
- 상태관리 : **Provider**
- 로컬저장소 : **SharedPreferences**

## 💡 주요 기능

## Tab1: Home Tab <img src="https://github.com/user-attachments/assets/21861b4b-16e5-4ffb-bec6-70b4fd762708" alt="홈" width="200" align="right">

- **👤사용자 개인정보**

  - 사용자 닉네임, 상태메시지 설정

  - 사용자 프로필 사진 갤러리/카메라로 설정

- **📅이번 주 리뷰 성과**

  - 리뷰(사진/텍스트 무관)를 작성한 날짜 체크

  - 주간 달력으로 일주일 동안 리뷰를 작성한 날짜 표시

  - 리뷰를 삭제해도 작성한 날짜는 유지

- **📊사용자 통계**

  - 현재 작성한 사진/텍스트 리뷰 개수, 리뷰 작성한 날 개수 표시

  - 리뷰를 삭제하면 통계 변화

- **🏅뱃지 및 업적**

  - 앱 사용중 특정 조건 달성 시 뱃지 지급

    - ex1) 첫 리뷰 작성: 첫 발걸음

    - ex2) 텍스트 리뷰 50개 작성: 텍스트 장인

    - ex3) 총 리뷰 100개 작성: 리뷰왕

  - 획득하지 못한 뱃지는 잠김 표시

  - 획득한 뱃지는 뱃지와 함께 업적명 표시

  - 뱃지 선택 시 뱃지 확대 및 설명(달성 조건) 표시

## Tab2: Gallery Tab <img src="https://github.com/user-attachments/assets/c8cd4957-bf84-4e97-983c-39c3102b9681" alt="갤러리" width="200" align="right">

- **📷사진 추가/수정/삭제**

  - 오른쪽 하단 플러스 버튼(+) 클릭 시 갤러리 혹은 카메라 중 선택하여 사진 추가

  - 사진과 함께 짧은 멘트 덧붙이기 가능

  - 사진을 등록한 시간을 timestamp로 표시

  - 추가한 사진 수정 및 삭제

- **🗂폴더 기능**

  - 갤러리의 추가한 사진을 폴더로 정리

  - 새 폴더 추가로 폴더 간 사진 이동

  - 폴더 여러개 선택 삭제
<br>
   
## Tab3: Review Tab <img src="https://github.com/user-attachments/assets/0f656c62-4c4a-4a7d-8065-77e1d742207c" alt="갤러리" width="200" align="right">

- **📝리뷰 추가/수정/삭제**

  - 오른쪽 하단 플러스 버튼(+) 클릭 시 제목, 작가, 장르, 리뷰 내용 작성

  - 작성한 리뷰 수정 및 삭제

  - 오른쪽 상단 리뷰 여러개 선택 삭제

- **🔀리뷰 정렬**

  - 제목/작가/장르/날짜 (오름차순/내림차순) 정렬

  - 기본: 날짜 순, 정렬기준 재선택시 오름차순/내림차순 변경

- **🌐리뷰 공유**

  - 리뷰의 스크린 샷 공유

  - 문자, 드라이브 등 다양하게 공유 가능

## Tab4: Search Tab <img src="https://github.com/user-attachments/assets/a72ec5a7-2eef-4020-8479-cfe9f35010c7" alt="검색" width="200" align="right">

- **🔎도서 검색 기능**

  - 상단의 검색 탭을 통해 도서 검색

  - 구글 API 호출로 전세계 도서의 제목, 작가명, 장르 검색

  - 최근 검색어 켜기: 최근 검색한 검색어를 저장해서 빠르게 재검색

    - 검색어 개별 및 전체 삭제

  - 최근 검색어 끄기: 최근 검색어가 숨겨지며 저장되지 않음

- **👍빠른 리뷰 추가 기능**

  - 검색한 도서 선택시 빠르게 텍스트 혹은 사진으로 리뷰 추가

    - 텍스트: 도서의 정보(제목, 작가, 장르 등) 자동 완성 (Tab3으로 전달)

    - 사진: 갤러리/카메라로 사진 추가 (Tab2으로 전달)

## 추가 라이브러리:

- **http** : Google Books API 호출
- **image_picker** : 이미지 업로드
- **device_info_plus** : 기기 정보 확인
- **path_provider** : 파일 저장 경로 확인
- **screenshot** : 화면 캡처
- **share_plus** : 공유 기능
