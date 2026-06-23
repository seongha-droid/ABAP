PROCESS BEFORE OUTPUT." PBO 모듈
  MODULE status_0100. " 버튼 설정, 화면 타이틀 설정
  MODULE set_alv.     " ALV 설정(컨테이너, 그리드, 필드 카탈로그 설정)

PROCESS AFTER INPUT.           " PAI 모듈
  MODULE EXIT AT EXIT-COMMAND. " EXIT 모듈(사용자가 버튼을 누른 후의 로직)
