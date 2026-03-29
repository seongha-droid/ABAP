*&---------------------------------------------------------------------*
*& Include          ZM_182_PRAC_1_TOP
*&---------------------------------------------------------------------*
TABLES: mara.

DATA: gt_mara TYPE TABLE OF mara.

PARAMETERS: p_mtart LIKE mara-mtart.
SELECT-OPTIONS: s_matnr FOR mara-matnr.
