@echo off
setlocal enabledelayedexpansion
set filename="%~nx1"
echo mejorar scans...

echo procesando archivo: %filename%

::pdf 2 img
pdfimages -j %filename% pdfcleaner_out

::delete non page images (too small ones to be a page)
echo descartando imágenes que no son página

for %%f in (pdfcleaner_out*.jpg) do (
  set imgheight=1000
  for /f "tokens=* USEBACKQ" %%i in (`magick identify -ping -format %%h %%f`) do ( set /a imgheight=%%i )
  ::echo !imgheight!
  if !imgheight! lss 100 ( del "%%f" )
 )

::pause
::exit /b 1

::clean scans

echo limpiando imágenes

set counter=0
for %%f in (pdfcleaner_out*.jpg) do (
  echo procesando %%f
  ::echo counter: !counter!
  if !counter! lss 10 (set counterS="0!counter!") else set counterS=!counter!
  ::echo counterS: !counterS!
  magick %%f -grayscale Rec709Luma -level 40%%,85%% ^( +clone -blur 0x20 ^) -compose Divide_src -composite pdfcleaner_final-!counterS!.jpg 
  set /a counter+=1
 )





::img 2 pdf
echo generando pdf
magick pdfcleaner_final-*.jpg -compress jpeg mejorado_%filename%

::delete temp files
echo borrando archivos temporales
del pdfcleaner_*.jpg

echo ******** mejora terminada, archivo listo *********.

pause