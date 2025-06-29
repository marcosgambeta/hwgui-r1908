//
// HWGUI - Harbour Win32 GUI library source code:
// C level print functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#define OEMRESOURCE

#include "hwingui.h"
#include <commctrl.h>

#include <hbapiitm.h>
#include <hbvm.h>
#include <hbstack.h>
#ifdef __XHARBOUR__
#include <hbfast.h>
#endif

#if !defined(GetDefaultPrinter) && defined(__DMC__)
BOOL WINAPI GetDefaultPrinterA(LPSTR, LPDWORD);
BOOL WINAPI GetDefaultPrinterW(LPWSTR, LPDWORD);
#ifdef UNICODE
#define GetDefaultPrinter GetDefaultPrinterW
#else
#define GetDefaultPrinter GetDefaultPrinterA
#endif
#endif

HB_FUNC(HWG_OPENPRINTER)
{
  void *hText;
  hwg_ret_HDC(CreateDC(HWG_NULLPTR, HB_PARSTR(1, &hText, HWG_NULLPTR), HWG_NULLPTR, HWG_NULLPTR));
  hb_strfree(hText);
}

HB_FUNC(HWG_OPENDEFAULTPRINTER)
{
  DWORD dwNeeded, dwReturned;
  HDC hDC;
  PRINTER_INFO_4 *pinfo4;
  PRINTER_INFO_5 *pinfo5;

  if (GetVersion() & 0x80000000) // Windows 98
  {
    EnumPrinters(PRINTER_ENUM_DEFAULT, HWG_NULLPTR, 5, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);

    pinfo5 = (PRINTER_INFO_5 *)hb_xgrab(dwNeeded);

    EnumPrinters(PRINTER_ENUM_DEFAULT, HWG_NULLPTR, 5, (PBYTE)pinfo5, dwNeeded, &dwNeeded, &dwReturned);

    hDC = CreateDC(HWG_NULLPTR, pinfo5->pPrinterName, HWG_NULLPTR, HWG_NULLPTR);
    if (hb_pcount() > 0)
    {
      HB_STORSTR(pinfo5->pPrinterName, 1);
    }

    hb_xfree(pinfo5);
  }
  else // Windows NT
  {
    EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);

    pinfo4 = (PRINTER_INFO_4 *)hb_xgrab(dwNeeded);

    EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, (PBYTE)pinfo4, dwNeeded, &dwNeeded, &dwReturned);
    hDC = CreateDC(HWG_NULLPTR, pinfo4->pPrinterName, HWG_NULLPTR, HWG_NULLPTR);
    if (hb_pcount() > 0)
    {
      HB_STORSTR(pinfo4->pPrinterName, 1);
    }

    hb_xfree(pinfo4);
  }
  hwg_ret_HDC(hDC);
}

HB_FUNC(HWG_GETDEFAULTPRINTER)
{
  DWORD dwNeeded, dwReturned;
  PRINTER_INFO_4 *pinfo4;
  PRINTER_INFO_5 *pinfo5;
  OSVERSIONINFO osvi;

  ZeroMemory(&osvi, sizeof(OSVERSIONINFO));
  osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);

  GetVersionEx(&osvi);

  if (osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS) // Windows 98
  {
    EnumPrinters(PRINTER_ENUM_DEFAULT, HWG_NULLPTR, 5, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);

    pinfo5 = (PRINTER_INFO_5 *)hb_xgrab(dwNeeded);

    EnumPrinters(PRINTER_ENUM_DEFAULT, HWG_NULLPTR, 5, (LPBYTE)pinfo5, dwNeeded, &dwNeeded, &dwReturned);

    HB_RETSTR(pinfo5->pPrinterName);
    hb_xfree(pinfo5);
  }
  else if (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT)
  {
    if (osvi.dwMajorVersion >= 5) /* Windows 2000 or later */
    {
      TCHAR PrinterDefault[256] = {0};
      DWORD BuffSize = 256;

      GetDefaultPrinter(PrinterDefault, &BuffSize);
      PrinterDefault[HB_SIZEOFARRAY(PrinterDefault) - 1] = 0;
      HB_RETSTR(PrinterDefault);
    }
    else // Windows NT
    {
      EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);

      pinfo4 = (PRINTER_INFO_4 *)hb_xgrab(dwNeeded);

      EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, (PBYTE)pinfo4, dwNeeded, &dwNeeded, &dwReturned);

      HB_RETSTR(pinfo4->pPrinterName);
      hb_xfree(pinfo4);
    }
  }
}

HB_FUNC(HWG_GETPRINTERS)
{
  DWORD dwNeeded, dwReturned;
  PBYTE pBuffer = HWG_NULLPTR;
  PRINTER_INFO_4 *pinfo4 = HWG_NULLPTR;
  PRINTER_INFO_5 *pinfo5 = HWG_NULLPTR;

  PHB_ITEM aMetr, temp;

  if (GetVersion() & 0x80000000) // Windows 98
  {
    EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 5, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);
    if (dwNeeded)
    {
      pBuffer = (PBYTE)hb_xgrab(dwNeeded);
      pinfo5 = (PRINTER_INFO_5 *)pBuffer;
      EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 5, pBuffer, dwNeeded, &dwNeeded, &dwReturned);
    }
  }
  else // Windows NT
  {
    EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);
    if (dwNeeded)
    {
      pBuffer = (PBYTE)hb_xgrab(dwNeeded);
      pinfo4 = (PRINTER_INFO_4 *)pBuffer;
      EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, pBuffer, dwNeeded, &dwNeeded, &dwReturned);
    }
  }
  if (dwReturned)
  {
    int i;

    aMetr = hb_itemArrayNew(dwReturned);

    for (i = 0; i < (int)dwReturned; i++)
    {
      if (pinfo4)
      {
        temp = HB_ITEMPUTSTR(HWG_NULLPTR, pinfo4->pPrinterName);
        pinfo4++;
      }
      else
      {
        temp = HB_ITEMPUTSTR(HWG_NULLPTR, pinfo5->pPrinterName);
        pinfo5++;
      }
      hb_itemArrayPut(aMetr, i + 1, temp);
      hb_itemRelease(temp);
    }
    hb_itemReturnRelease(aMetr);
  }
  else
  {
    hb_ret();
  }

  if (pBuffer)
  {
    hb_xfree(pBuffer);
  }
}

HB_FUNC(HWG_SETPRINTERMODE)
{
  void *hPrinterName;
  LPCTSTR lpPrinterName = HB_PARSTR(1, &hPrinterName, HWG_NULLPTR);
  HANDLE hPrinter = (HB_ISNIL(2)) ? HWG_NULLPTR : (HANDLE)HB_PARHANDLE(2);
  long int nSize;
  PDEVMODE pdm;

  if (!hPrinter)
  {
    OpenPrinter((LPTSTR)lpPrinterName, &hPrinter, HWG_NULLPTR);
  }

  if (hPrinter)
  {
    /* Determine the size of DEVMODE structure */
    nSize = DocumentProperties(HWG_NULLPTR, hPrinter, (LPTSTR)lpPrinterName, HWG_NULLPTR, HWG_NULLPTR, 0);
    pdm = (PDEVMODE)GlobalAlloc(GPTR, nSize);

    /* Get the printer mode */
    DocumentProperties(HWG_NULLPTR, hPrinter, (LPTSTR)lpPrinterName, pdm, HWG_NULLPTR, DM_OUT_BUFFER);

    /* Changing of values */
    if (!HB_ISNIL(3))
    {
      pdm->dmOrientation = (short)hb_parni(3);
      pdm->dmFields = pdm->dmFields | DM_ORIENTATION;
    }

    // Call DocumentProperties() to change the values
    DocumentProperties(HWG_NULLPTR, hPrinter, (LPTSTR)lpPrinterName, pdm, pdm, DM_OUT_BUFFER | DM_IN_BUFFER);

    // ᮧ����� ���⥪�� ���ன�⢠ �ਭ��
    hwg_ret_HDC(CreateDC(HWG_NULLPTR, lpPrinterName, HWG_NULLPTR, pdm));
    HB_STOREHANDLE(hPrinter, 2);
    GlobalFree(pdm);
  }

  hb_strfree(hPrinterName);
}

HB_FUNC(HWG_CLOSEPRINTER)
{
  HANDLE hPrinter = (HANDLE)HB_PARHANDLE(1);
  ClosePrinter(hPrinter);
}

HB_FUNC(HWG_STARTDOC)
{
  void *hText;
  DOCINFO di;

  di.cbSize = sizeof(DOCINFO);
  di.lpszDocName = HB_PARSTR(2, &hText, HWG_NULLPTR);
  di.lpszOutput = HWG_NULLPTR;
  di.lpszDatatype = HWG_NULLPTR;
  di.fwType = 0;

  hb_retnl((LONG)StartDoc(hwg_par_HDC(1), &di));
  hb_strfree(hText);
}

HB_FUNC(HWG_ENDDOC)
{
  EndDoc(hwg_par_HDC(1));
}

HB_FUNC(HWG_ABORTDOC)
{
  AbortDoc(hwg_par_HDC(1));
}

HB_FUNC(HWG_STARTPAGE)
{
  hb_retnl((LONG)StartPage(hwg_par_HDC(1)));
}

HB_FUNC(HWG_ENDPAGE)
{
  hb_retnl((LONG)EndPage(hwg_par_HDC(1)));
}

/*
 * HORZRES	Width, in pixels, of the screen.
 * VERTRES	Height, in raster lines, of the screen.
 * HORZSIZE	Width, in millimeters, of the physical screen.
 * VERTSIZE	Height, in millimeters, of the physical screen.
 * LOGPIXELSX	Number of pixels per logical inch along the screen width.
 * LOGPIXELSY	Number of pixels per logical inch along the screen height.
 *
 */
HB_FUNC(HWG_GETDEVICEAREA)
{
  HDC hDC = hwg_par_HDC(1);
  PHB_ITEM temp;
  PHB_ITEM aMetr = hb_itemArrayNew(11);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, HORZRES));
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, VERTRES));
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, HORZSIZE));
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, VERTSIZE));
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, LOGPIXELSX));
  hb_itemArrayPut(aMetr, 5, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, LOGPIXELSY));
  hb_itemArrayPut(aMetr, 6, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, RASTERCAPS));
  hb_itemArrayPut(aMetr, 7, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, PHYSICALWIDTH));
  hb_itemArrayPut(aMetr, 8, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, PHYSICALHEIGHT));
  hb_itemArrayPut(aMetr, 9, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, PHYSICALOFFSETY));
  hb_itemArrayPut(aMetr, 10, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, PHYSICALOFFSETX));
  hb_itemArrayPut(aMetr, 11, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}

HB_FUNC(HWG_CREATEENHMETAFILE)
{
  HWND hWnd = hwg_par_HWND(1);
  HDC hDCref = GetDC(hWnd), hDCmeta;
  void *hFileName;
  int iWidthMM, iHeightMM, iWidthPels, iHeightPels;
  RECT rc;
  // char cres[80];

  /* Determine the picture frame dimensions.
   * iWidthMM is the display width in millimeters.
   * iHeightMM is the display height in millimeters.
   * iWidthPels is the display width in pixels.
   * iHeightPels is the display height in pixels
   */

  iWidthMM = GetDeviceCaps(hDCref, HORZSIZE);
  iHeightMM = GetDeviceCaps(hDCref, VERTSIZE);
  iWidthPels = GetDeviceCaps(hDCref, HORZRES);
  iHeightPels = GetDeviceCaps(hDCref, VERTRES);

  /*
   * Retrieve the coordinates of the client
   * rectangle, in pixels.
   */

  GetClientRect(hWnd, &rc);
  // sprintf( cres,"%d %d %d %d %d %d %d %d",iWidthMM, iHeightMM, iWidthPels,
  // iHeightPels,rc.left,rc.top,rc.right,rc.bottom ); MessageBox(GetActiveWindow(), cres, "", MB_OK |
  // MB_ICONINFORMATION);

  /*
   * Convert client coordinates to .01-mm units.
   * Use iWidthMM, iWidthPels, iHeightMM, and
   * iHeightPels to determine the number of
   * .01-millimeter units per pixel in the x-
   *  and y-directions.
   */

  rc.left = (rc.left * iWidthMM * 100) / iWidthPels;
  rc.top = (rc.top * iHeightMM * 100) / iHeightPels;
  rc.right = (rc.right * iWidthMM * 100) / iWidthPels;
  rc.bottom = (rc.bottom * iHeightMM * 100) / iHeightPels;

  hDCmeta = CreateEnhMetaFile(hDCref, HB_PARSTR(2, &hFileName, HWG_NULLPTR), &rc, HWG_NULLPTR);
  ReleaseDC(hWnd, hDCref);
  hwg_ret_HDC(hDCmeta);
  hb_strfree(hFileName);
}

HB_FUNC(HWG_CREATEMETAFILE)
{
  HDC hDCref = hwg_par_HDC(1), hDCmeta;
  void *hFileName;
  int iWidthMM, iHeightMM;
  RECT rc;

  /* Determine the picture frame dimensions.
   * iWidthMM is the display width in millimeters.
   * iHeightMM is the display height in millimeters.
   * iWidthPels is the display width in pixels.
   * iHeightPels is the display height in pixels
   */

  iWidthMM = GetDeviceCaps(hDCref, HORZSIZE);
  iHeightMM = GetDeviceCaps(hDCref, VERTSIZE);

  /*
   * Convert client coordinates to .01-mm units.
   * Use iWidthMM, iWidthPels, iHeightMM, and
   * iHeightPels to determine the number of
   * .01-millimeter units per pixel in the x-
   *  and y-directions.
   */

  rc.left = 0;
  rc.top = 0;
  rc.right = iWidthMM * 100;
  rc.bottom = iHeightMM * 100;

  hDCmeta = CreateEnhMetaFile(hDCref, HB_PARSTR(2, &hFileName, HWG_NULLPTR), &rc, HWG_NULLPTR);
  hwg_ret_HDC(hDCmeta);
  hb_strfree(hFileName);
}

HB_FUNC(HWG_CLOSEENHMETAFILE)
{
  HB_RETHANDLE(CloseEnhMetaFile(hwg_par_HDC(1)));
}

HB_FUNC(HWG_DELETEENHMETAFILE)
{
  HB_RETHANDLE((LONG)DeleteEnhMetaFile((HENHMETAFILE)HB_PARHANDLE(1))); // TODO: revisar (o retorno � BOOL)
}

HB_FUNC(HWG_PLAYENHMETAFILE)
{
  HDC hDC = hwg_par_HDC(1);
  RECT rc;

  if (hb_pcount() > 2)
  {
    rc.left = hb_parni(3);
    rc.top = hb_parni(4);
    rc.right = hb_parni(5);
    rc.bottom = hb_parni(6);
  }
  else
  {
    GetClientRect(WindowFromDC(hDC), &rc);
  }
  hb_retnl((LONG)PlayEnhMetaFile(hDC, (HENHMETAFILE)HB_PARHANDLE(2), &rc));
}

HB_FUNC(HWG_PRINTENHMETAFILE)
{
  HDC hDC = hwg_par_HDC(1);
  // DOCINFO di;
  RECT rc;

  /*
     di.cbSize = sizeof(DOCINFO);
     di.lpszDocName = hb_parc(3);
     di.lpszOutput = HWG_NULLPTR;
     di.lpszDatatype = HWG_NULLPTR;
     di.fwType = 0;
   */

  SetRect(&rc, 0, 0, GetDeviceCaps(hDC, HORZRES), GetDeviceCaps(hDC, VERTRES));

  // StartDoc(hDC, &di);
  StartPage(hDC);
  hb_retnl((LONG)PlayEnhMetaFile(hDC, (HENHMETAFILE)HB_PARHANDLE(2), &rc));
  EndPage(hDC);
  // EndDoc(hDC);
}

HB_FUNC(HWG_SETDOCUMENTPROPERTIES)
{
  BOOL bW9X, Result = FALSE;
  HDC hDC = hwg_par_HDC(1);
  OSVERSIONINFO osvi;
  osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
  GetVersionEx(&osvi);
  bW9X = (osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS);
  if (hDC)
  {
    HANDLE hPrinter;
    void *hPrinterName;
    LPCTSTR lpPrinterName = HB_PARSTR(2, &hPrinterName, HWG_NULLPTR);

    if (OpenPrinter((LPTSTR)lpPrinterName, &hPrinter, HWG_NULLPTR))
    {

      PDEVMODE pDevMode = HWG_NULLPTR;
      LONG lSize = DocumentProperties(0, hPrinter, (LPTSTR)lpPrinterName, pDevMode, pDevMode, 0);

      if (lSize > 0)
      {
        pDevMode = (PDEVMODE)hb_xgrab(lSize);

        if (pDevMode && DocumentProperties(0, hPrinter, (LPTSTR)lpPrinterName, pDevMode, pDevMode, DM_OUT_BUFFER) ==
                            IDOK) // Get the current settings
        {
          BOOL bAskUser = HB_ISBYREF(3) || HB_ISBYREF(4) || HB_ISBYREF(5) || HB_ISBYREF(6) || HB_ISBYREF(7) ||
                          HB_ISBYREF(8) || HB_ISBYREF(9) || HB_ISBYREF(10); // x 20070421
          DWORD dInit = 0;                                                  // x 20070421
          DWORD fMode;
          BOOL bCustomFormSize =
              (HB_ISNUM(9) && hb_parnl(9) > 0) && (HB_ISNUM(10) && hb_parnl(10) > 0); // Must set both Length & Width

          if (bCustomFormSize)
          {
            pDevMode->dmPaperLength = (short)hb_parnl(9);
            dInit |= DM_PAPERLENGTH;

            pDevMode->dmPaperWidth = (short)hb_parnl(10);
            dInit |= DM_PAPERWIDTH;

            pDevMode->dmPaperSize = DMPAPER_USER;
            dInit |= DM_PAPERSIZE;
          }
          else
          {
            if (HB_ISCHAR(3)) // this doesn't work for Win9X
            {
              if (!bW9X)
              {
                void *hFormName;
                HB_SIZE len;
                LPCTSTR lpFormName = HB_PARSTR(3, &hFormName, &len);

                if (lpFormName && len && len < CCHFORMNAME)
                {
                  memcpy(pDevMode->dmFormName, lpFormName, (len + 1) * sizeof(TCHAR));
                  dInit |= DM_FORMNAME;
                }
                hb_strfree(hFormName);
              }
            }
            else if (HB_ISNUM(3) && hb_parnl(3)) // 22/02/2007 don't change if 0
            {
              pDevMode->dmPaperSize = (short)hb_parnl(3);
              dInit |= DM_PAPERSIZE;
            }
          }

          if (HB_ISLOG(4))
          {
            pDevMode->dmOrientation = (short)(hb_parl(4) ? 2 : 1);
            dInit |= DM_ORIENTATION;
          }

          if (HB_ISNUM(5) && hb_parnl(5) > 0)
          {
            pDevMode->dmCopies = (short)hb_parnl(5);
            dInit |= DM_COPIES;
          }

          if (HB_ISNUM(6) && hb_parnl(6)) // 22/02/2007 don't change if 0
          {
            pDevMode->dmDefaultSource = (short)hb_parnl(6);
            dInit |= DM_DEFAULTSOURCE;
          }

          if (HB_ISNUM(7) && hb_parnl(7)) // 22/02/2007 don't change if 0
          {
            pDevMode->dmDuplex = (short)hb_parnl(7);
            dInit |= DM_DUPLEX;
          }

          if (HB_ISNUM(8) && hb_parnl(8)) // 22/02/2007 don't change if 0
          {
            pDevMode->dmPrintQuality = (short)hb_parnl(8);
            dInit |= DM_PRINTQUALITY;
          }

          fMode = DM_IN_BUFFER | DM_OUT_BUFFER;

          if (bAskUser)
          {
            fMode |= DM_IN_PROMPT;
          }

          pDevMode->dmFields = dInit;

          /* NOTES:
             For unknown reasons, Windows98/ME returns IDCANCEL if user clicks OK without changing anything in
             DocumentProperties. Therefore, we ignore the return value in Win9x, and assume user clicks OK. IOW,
             DocumentProperties is not cancelable in Win9X.
           */
          if (DocumentProperties(0, hPrinter, (LPTSTR)lpPrinterName, pDevMode, pDevMode, fMode) == IDOK || bW9X)
          {
            if (HB_ISBYREF(3) && !bCustomFormSize)
            {
              if (HB_ISCHAR(3))
              {
                if (!bW9X)
                {
                  HB_STORSTR((LPCTSTR)pDevMode->dmFormName, 3);
                }
              }
              else
              {
                hb_stornl((LONG)pDevMode->dmPaperSize, 3);
              }
            }
            if (HB_ISBYREF(4))
            {
              hb_storl(pDevMode->dmOrientation == 2, 4);
            }
            if (HB_ISBYREF(5))
            {
              hb_stornl((LONG)pDevMode->dmCopies, 5);
            }
            if (HB_ISBYREF(6))
            {
              hb_stornl((LONG)pDevMode->dmDefaultSource, 6);
            }
            if (HB_ISBYREF(7))
            {
              hb_stornl((LONG)pDevMode->dmDuplex, 7);
            }
            if (HB_ISBYREF(8))
            {
              hb_stornl((LONG)pDevMode->dmPrintQuality, 8);
            }
            if (HB_ISBYREF(9))
            {
              hb_stornl((LONG)pDevMode->dmPaperLength, 9);
            }
            if (HB_ISBYREF(10))
            {
              hb_stornl((LONG)pDevMode->dmPaperWidth, 10);
            }

            Result = (BOOL)(INT_PTR)ResetDC(hDC, pDevMode);
          }

          hb_xfree(pDevMode);
        }
      }
      ClosePrinter(hPrinter);
    }
    hb_strfree(hPrinterName);
  }
  hb_retl(Result);
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(SETPRINTERMODE, HWG_SETPRINTERMODE);
HB_FUNC_TRANSLATE(CLOSEPRINTER, HWG_CLOSEPRINTER);
HB_FUNC_TRANSLATE(GETDEVICEAREA, HWG_GETDEVICEAREA);
HB_FUNC_TRANSLATE(CREATEENHMETAFILE, HWG_CREATEENHMETAFILE);
HB_FUNC_TRANSLATE(CREATEMETAFILE, HWG_CREATEMETAFILE);
HB_FUNC_TRANSLATE(CLOSEENHMETAFILE, HWG_CLOSEENHMETAFILE);
HB_FUNC_TRANSLATE(DELETEENHMETAFILE, HWG_DELETEENHMETAFILE);
HB_FUNC_TRANSLATE(PLAYENHMETAFILE, HWG_PLAYENHMETAFILE);
HB_FUNC_TRANSLATE(PRINTENHMETAFILE, HWG_PRINTENHMETAFILE);
#endif
