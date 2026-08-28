//
// FreeImage wrappers for Harbour/HwGUI
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#ifdef __GNUC__
#pragma GCC diagnostic ignored "-Wcast-function-type"
#endif

#include "hwingui.h"
#include <hbapiitm.h>
#include <hbvm.h>
#include "freeimage.h"

#define hwg_par_FIBITMAP(n) (FIBITMAP *)HB_PARHANDLE(n)

typedef char *(WINAPI *FREEIMAGE_GETVERSION)(void);

#if defined(__cplusplus)
typedef FIBITMAP *(WINAPI *FREEIMAGE_LOADFROMHANDLE)(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle,
                                                     int32_t flags);
typedef FIBITMAP *(WINAPI *FREEIMAGE_LOAD)(FREE_IMAGE_FORMAT fif, const char *filename, int32_t flags);
typedef BOOL(WINAPI *FREEIMAGE_SAVE)(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const char *filename, int32_t flags);
typedef FIBITMAP *(WINAPI *FREEIMAGE_ALLOCATE)(int32_t width, int32_t height, int32_t bpp, uint32_t red_mask, uint32_t green_mask,
                                               uint32_t blue_mask);
typedef FIBITMAP *(WINAPI *FREEIMAGE_CONVERTFROMRAWBITS)(uint8_t *bits, int32_t width, int32_t height, int32_t pitch, uint32_t bpp,
                                                         uint32_t red_mask, uint32_t green_mask, uint32_t blue_mask,
                                                         BOOL topdown);
typedef void(WINAPI *FREEIMAGE_CONVERTTORAWBITS)(uint8_t *bits, FIBITMAP *dib, int32_t pitch, uint32_t bpp, uint32_t red_mask,
                                                 uint32_t green_mask, uint32_t blue_mask, BOOL topdown);
#else
typedef FIBITMAP *(WINAPI *FREEIMAGE_LOADFROMHANDLE)(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle,
                                                     int32_t flags FI_DEFAULT(0));
typedef FIBITMAP *(WINAPI *FREEIMAGE_LOAD)(FREE_IMAGE_FORMAT fif, const char *filename, int32_t flags FI_DEFAULT(0));
typedef FIBITMAP *(WINAPI *FREEIMAGE_ALLOCATE)(int32_t width, int32_t height, int32_t bpp, uint32_t red_mask FI_DEFAULT(0),
                                               uint32_t green_mask FI_DEFAULT(0), uint32_t blue_mask FI_DEFAULT(0));
typedef BOOL(WINAPI *FREEIMAGE_SAVE)(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const char *filename,
                                     int32_t flags FI_DEFAULT(0));
typedef FIBITMAP *(WINAPI *FREEIMAGE_CONVERTFROMRAWBITS)(uint8_t *bits, int32_t width, int32_t height, int32_t pitch, uint32_t bpp,
                                                         uint32_t red_mask, uint32_t green_mask, uint32_t blue_mask,
                                                         BOOL topdown FI_DEFAULT(FALSE));
typedef void(WINAPI *FREEIMAGE_CONVERTTORAWBITS)(uint8_t *bits, FIBITMAP *dib, int32_t pitch, uint32_t bpp, uint32_t red_mask,
                                                 uint32_t green_mask, uint32_t blue_mask,
                                                 BOOL topdown FI_DEFAULT(FALSE));
#endif

typedef void(WINAPI *FREEIMAGE_UNLOAD)(FIBITMAP *dib);
typedef FREE_IMAGE_FORMAT(WINAPI *FREEIMAGE_GETFIFFROMFILENAME)(const char *filename);
typedef uint32_t(WINAPI *FREEIMAGE_GETWIDTH)(FIBITMAP *dib);
typedef uint32_t(WINAPI *FREEIMAGE_GETHEIGHT)(FIBITMAP *dib);
typedef uint8_t *(WINAPI *FREEIMAGE_GETBITS)(FIBITMAP *dib);
typedef BITMAPINFO *(WINAPI *FREEIMAGE_GETINFO)(FIBITMAP *dib);
typedef BITMAPINFOHEADER *(WINAPI *FREEIMAGE_GETINFOHEADER)(FIBITMAP *dib);
typedef FIBITMAP *(WINAPI *FREEIMAGE_RESCALE)(FIBITMAP *dib, int32_t dst_width, int32_t dst_height, FREE_IMAGE_FILTER filter);
typedef RGBQUAD *(WINAPI *FREEIMAGE_GETPALETTE)(FIBITMAP *dib);
typedef uint32_t(WINAPI *FREEIMAGE_GETBPP)(FIBITMAP *dib);
typedef BOOL(WINAPI *FREEIMAGE_SETCHANNEL)(FIBITMAP *dib, FIBITMAP *dib8, FREE_IMAGE_COLOR_CHANNEL channel);
typedef uint8_t *(WINAPI *FREEIMAGE_GETSCANLINE)(FIBITMAP *dib, int32_t scanline);
typedef uint32_t(WINAPI *FREEIMAGE_GETPITCH)(FIBITMAP *dib);
typedef int16_t(WINAPI *FREEIMAGE_GETIMAGETYPE)(FIBITMAP *dib);
typedef uint32_t(WINAPI *FREEIMAGE_GETCOLORSUSED)(FIBITMAP *dib);
typedef FIBITMAP *(WINAPI *FREEIMAGE_ROTATECLASSIC)(FIBITMAP *dib, double angle);
typedef uint32_t(WINAPI *FREEIMAGE_GETDOTSPERMETERX)(FIBITMAP *dib);
typedef uint32_t(WINAPI *FREEIMAGE_GETDOTSPERMETERY)(FIBITMAP *dib);
typedef void(WINAPI *FREEIMAGE_SETDOTSPERMETERX)(FIBITMAP *dib, uint32_t res);
typedef void(WINAPI *FREEIMAGE_SETDOTSPERMETERY)(FIBITMAP *dib, uint32_t res);
typedef BOOL(WINAPI *FREEIMAGE_PASTE)(FIBITMAP *dst, FIBITMAP *src, int32_t left, int32_t top, int32_t alpha);
typedef FIBITMAP *(WINAPI *FREEIMAGE_COPY)(FIBITMAP *dib, int32_t left, int32_t top, int32_t right, int32_t bottom);
typedef BOOL(WINAPI *FREEIMAGE_SETBACKGROUNDCOLOR)(FIBITMAP *dib, RGBQUAD *bkcolor);
typedef BOOL(WINAPI *FREEIMAGE_INVERT)(FIBITMAP *dib);
typedef FIBITMAP *(WINAPI *FREEIMAGE_CONVERTTO8BITS)(FIBITMAP *dib);
typedef FIBITMAP *(WINAPI *FREEIMAGE_CONVERTTOGREYSCALE)(FIBITMAP *dib);
typedef BOOL(WINAPI *FREEIMAGE_FLIPVERTICAL)(FIBITMAP *dib);
typedef FIBITMAP *(WINAPI *FREEIMAGE_THRESHOLD)(FIBITMAP *dib, uint8_t T);

typedef BOOL(WINAPI *FREEIMAGE_GETPIXELINDEX)(FIBITMAP *dib, uint32_t x, uint32_t y, uint8_t *value);
typedef BOOL(WINAPI *FREEIMAGE_GETPIXELCOLOR)(FIBITMAP *dib, uint32_t x, uint32_t y, RGBQUAD *value);
typedef BOOL(WINAPI *FREEIMAGE_SETPIXELINDEX)(FIBITMAP *dib, uint32_t x, uint32_t y, uint8_t *value);
typedef BOOL(WINAPI *FREEIMAGE_SETPIXELCOLOR)(FIBITMAP *dib, uint32_t x, uint32_t y, RGBQUAD *value);

static HINSTANCE hFreeImageDll = nullptr;
static FREEIMAGE_LOAD pLoad = nullptr;
static FREEIMAGE_LOADFROMHANDLE pLoadFromHandle = nullptr;
static FREEIMAGE_UNLOAD pUnload = nullptr;
static FREEIMAGE_ALLOCATE pAllocate = nullptr;
static FREEIMAGE_SAVE pSave = nullptr;
static FREEIMAGE_GETFIFFROMFILENAME pGetfiffromfile = nullptr;
static FREEIMAGE_GETWIDTH pGetwidth = nullptr;
static FREEIMAGE_GETHEIGHT pGetheight = nullptr;
static FREEIMAGE_GETBITS pGetbits = nullptr;
static FREEIMAGE_GETINFO pGetinfo = nullptr;
static FREEIMAGE_GETINFOHEADER pGetinfoHead = nullptr;
static FREEIMAGE_CONVERTFROMRAWBITS pConvertFromRawBits = nullptr;
static FREEIMAGE_RESCALE pRescale = nullptr;
static FREEIMAGE_GETPALETTE pGetPalette = nullptr;
static FREEIMAGE_GETBPP pGetBPP = nullptr;
static FREEIMAGE_SETCHANNEL pSetChannel = nullptr;
static FREEIMAGE_GETSCANLINE pGetScanline = nullptr;
static FREEIMAGE_CONVERTTORAWBITS pConvertToRawBits = nullptr;
static FREEIMAGE_GETPITCH pGetPitch = nullptr;
static FREEIMAGE_GETIMAGETYPE pGetImageType = nullptr;
static FREEIMAGE_GETCOLORSUSED pGetColorsUsed = nullptr;
static FREEIMAGE_ROTATECLASSIC pRotateClassic = nullptr;
static FREEIMAGE_GETDOTSPERMETERX pGetDotsPerMeterX = nullptr;
static FREEIMAGE_GETDOTSPERMETERY pGetDotsPerMeterY = nullptr;
static FREEIMAGE_SETDOTSPERMETERX pSetDotsPerMeterX = nullptr;
static FREEIMAGE_SETDOTSPERMETERY pSetDotsPerMeterY = nullptr;
static FREEIMAGE_PASTE pPaste = nullptr;
static FREEIMAGE_COPY pCopy = nullptr;
static FREEIMAGE_SETBACKGROUNDCOLOR pSetBackgroundColor = nullptr;
static FREEIMAGE_INVERT pInvert = nullptr;
static FREEIMAGE_CONVERTTO8BITS pConvertTo8Bits = nullptr;
static FREEIMAGE_CONVERTTOGREYSCALE pConvertToGreyscale = nullptr;
static FREEIMAGE_FLIPVERTICAL pFlipVertical = nullptr;
static FREEIMAGE_THRESHOLD pThreshold = nullptr;
static FREEIMAGE_GETPIXELINDEX pGetPixelIndex = nullptr;
static FREEIMAGE_GETPIXELCOLOR pGetPixelColor = nullptr;
static FREEIMAGE_SETPIXELINDEX pSetPixelIndex = nullptr;
static FREEIMAGE_SETPIXELCOLOR pSetPixelColor = nullptr;
static void SET_FREEIMAGE_MARKER(BITMAPINFOHEADER *bmih, FIBITMAP *dib);

fi_handle g_load_address;

BOOL s_freeImgInit(void)
{
  if (!hFreeImageDll) {
    hFreeImageDll = LoadLibrary(TEXT("FreeImage.dll"));
    if (!hFreeImageDll) {
      MessageBox(GetActiveWindow(), TEXT("Library not loaded"), TEXT("FreeImage.dll"), MB_OK | MB_ICONSTOP);
      return 0;
    }
  }
  return 1;
}

static FARPROC s_getFunction(FARPROC h, LPCSTR funcname)
{
  if (!h) {
    if (!hFreeImageDll && !s_freeImgInit()) {
      return nullptr;
    } else {
      return GetProcAddress(hFreeImageDll, funcname);
    }
  } else {
    return h;
  }
}

HB_FUNC(FI_INIT)
{
  hb_retl(s_freeImgInit());
}

HB_FUNC(FI_END)
{
  if (hFreeImageDll) {
    FreeLibrary(hFreeImageDll);
    hFreeImageDll = nullptr;
    pLoad = nullptr;
    pUnload = nullptr;
    pAllocate = nullptr;
    pSave = nullptr;
    pGetfiffromfile = nullptr;
    pGetwidth = nullptr;
    pGetheight = nullptr;
    pGetbits = nullptr;
    pGetinfo = nullptr;
    pGetinfoHead = nullptr;
    pConvertFromRawBits = nullptr;
    pRescale = nullptr;
    pGetPalette = nullptr;
    pGetBPP = nullptr;
    pSetChannel = nullptr;
    pGetScanline = nullptr;
    pConvertToRawBits = nullptr;
    pGetPitch = nullptr;
    pGetImageType = nullptr;
    pGetColorsUsed = nullptr;
    pRotateClassic = nullptr;
    pGetDotsPerMeterX = nullptr;
    pGetDotsPerMeterY = nullptr;
    pSetDotsPerMeterX = nullptr;
    pSetDotsPerMeterY = nullptr;
    pPaste = nullptr;
    pCopy = nullptr;
    pSetBackgroundColor = nullptr;
    pInvert = nullptr;
    pConvertTo8Bits = nullptr;
    pConvertToGreyscale = nullptr;
    pFlipVertical = nullptr;
    pThreshold = nullptr;
    pGetPixelIndex = nullptr;
    pGetPixelColor = nullptr;
    pSetPixelIndex = nullptr;
    pSetPixelColor = nullptr;
  }
}

HB_FUNC(FI_VERSION)
{
  FREEIMAGE_GETVERSION pFunc = (FREEIMAGE_GETVERSION)s_getFunction(nullptr, "_FreeImage_GetVersion@0");

  hb_retc((pFunc) ? pFunc() : "");
}

HB_FUNC(FI_UNLOAD)
{
  pUnload = (FREEIMAGE_UNLOAD)s_getFunction((FARPROC)pUnload, "_FreeImage_Unload@4");

  if (pUnload) {
    pUnload(hwg_par_FIBITMAP(1));
  }
}

HB_FUNC(FI_LOAD)
{
  pLoad = (FREEIMAGE_LOAD)s_getFunction((FARPROC)pLoad, "_FreeImage_Load@12");
  pGetfiffromfile =
      (FREEIMAGE_GETFIFFROMFILENAME)s_getFunction((FARPROC)pGetfiffromfile, "_FreeImage_GetFIFFromFilename@4");

  if (pGetfiffromfile && pLoad) {
    const char *name = hb_parc(1);
    hb_retnint((uintptr_t)pLoad(pGetfiffromfile(name), name, (hb_pcount() > 1) ? hb_parni(2) : 0));
  } else {
    hb_retnl(0);
  }
}

// 24/03/2006 - <maurilio.longo@libero.it>
//              As the original freeimage's fi_Load() that has the filetype as first parameter
HB_FUNC(FI_LOADTYPE)
{
  pLoad = (FREEIMAGE_LOAD)s_getFunction((FARPROC)pLoad, "_FreeImage_Load@12");

  if (pLoad) {
    const char *name = hb_parc(2);
    hb_retnint((uintptr_t)pLoad((enum FREE_IMAGE_FORMAT)hb_parni(1), name, (hb_pcount() > 2) ? hb_parni(3) : 0));
  } else {
    hb_retnl(0);
  }
}

HB_FUNC(FI_SAVE)
{
  pSave = (FREEIMAGE_SAVE)s_getFunction((FARPROC)pSave, "_FreeImage_Save@16");
  pGetfiffromfile =
      (FREEIMAGE_GETFIFFROMFILENAME)s_getFunction((FARPROC)pGetfiffromfile, "_FreeImage_GetFIFFromFilename@4");

  if (pGetfiffromfile && pSave) {
    const char *name = hb_parc(2);
    hb_retl((BOOL)pSave(pGetfiffromfile(name), hwg_par_FIBITMAP(1), name, (hb_pcount() > 2) ? hb_parni(3) : 0));
  } else {
    hb_retl(FALSE);
  }
}

// 24/03/2006 - <maurilio.longo@libero.it>
//              As the original freeimage's fi_Save() that has the filetype as first parameter
HB_FUNC(FI_SAVETYPE)
{
  pSave = (FREEIMAGE_SAVE)s_getFunction((FARPROC)pSave, "_FreeImage_Save@16");

  if (pSave) {
    const char *name = hb_parc(3);
    hb_retl((BOOL)pSave((enum FREE_IMAGE_FORMAT)hb_parni(1), hwg_par_FIBITMAP(2), name,
                        (hb_pcount() > 3) ? hb_parni(4) : 0));
  } else {
    hb_retl(FALSE);
  }
}

HB_FUNC(FI_GETWIDTH)
{
  pGetwidth = (FREEIMAGE_GETWIDTH)s_getFunction((FARPROC)pGetwidth, "_FreeImage_GetWidth@4");

  hb_retnl((pGetwidth) ? pGetwidth(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC(FI_GETHEIGHT)
{
  pGetheight = (FREEIMAGE_GETHEIGHT)s_getFunction((FARPROC)pGetheight, "_FreeImage_GetHeight@4");

  hb_retnl((pGetheight) ? pGetheight(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC(FI_GETBPP)
{
  pGetBPP = (FREEIMAGE_GETBPP)s_getFunction((FARPROC)pGetBPP, "_FreeImage_GetBPP@4");

  hb_retnl((pGetBPP) ? pGetBPP(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC(FI_GETIMAGETYPE)
{
  pGetImageType = (FREEIMAGE_GETIMAGETYPE)s_getFunction((FARPROC)pGetImageType, "_FreeImage_GetImageType@4");

  hb_retnl((pGetImageType) ? pGetImageType(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC(FI_2BITMAP)
{
  FIBITMAP *dib = hwg_par_FIBITMAP(1);
  HDC hDC = GetDC(0);

  pGetbits = (FREEIMAGE_GETBITS)s_getFunction((FARPROC)pGetbits, "_FreeImage_GetBits@4");
  pGetinfo = (FREEIMAGE_GETINFO)s_getFunction((FARPROC)pGetinfo, "_FreeImage_GetInfo@4");
  pGetinfoHead = (FREEIMAGE_GETINFOHEADER)s_getFunction((FARPROC)pGetinfoHead, "_FreeImage_GetInfoHeader@4");

  hb_retnint((intptr_t)CreateDIBitmap(hDC, pGetinfoHead(dib), CBM_INIT, pGetbits(dib), pGetinfo(dib), DIB_RGB_COLORS));

  ReleaseDC(nullptr, hDC);
}

// 24/02/2005 - <maurilio.longo@libero.it>
// from internet, possibly code from win32 sdk
static HANDLE CreateDIB(DWORD dwWidth, DWORD dwHeight, WORD wBitCount)
{
  BITMAPINFOHEADER bi;     // bitmap header
  LPBITMAPINFOHEADER lpbi; // pointer to BITMAPINFOHEADER
  DWORD dwLen;             // size of memory block
  HANDLE hDIB;
  DWORD dwBytesPerLine; // Number of bytes per scanline

  // Make sure bits per pixel is valid
  if (wBitCount <= 1) {
    wBitCount = 1;
  } else if (wBitCount <= 4) {
    wBitCount = 4;
  } else if (wBitCount <= 8) {
    wBitCount = 8;
  } else if (wBitCount <= 24) {
    wBitCount = 24;
  } else {
    wBitCount = 4; // set default value to 4 if parameter is bogus
  }

  // initialize BITMAPINFOHEADER
  bi.biSize = sizeof(BITMAPINFOHEADER);
  bi.biWidth = dwWidth;      // fill in width from parameter
  bi.biHeight = dwHeight;    // fill in height from parameter
  bi.biPlanes = 1;           // must be 1
  bi.biBitCount = wBitCount; // from parameter
  bi.biCompression = BI_RGB;
  bi.biSizeImage = 0; // 0's here mean "default"
  bi.biXPelsPerMeter = 0;
  bi.biYPelsPerMeter = 0;
  bi.biClrUsed = 0;
  bi.biClrImportant = 0;

  // calculate size of memory block required to store the DIB.  This
  // block should be big enough to hold the BITMAPINFOHEADER, the color
  // table, and the bits
  dwBytesPerLine = (((wBitCount * dwWidth) + 31) / 32 * 4);

  // only 24 bit DIBs supported
  dwLen = bi.biSize + 0 /* PaletteSize((LPSTR)&bi) */ + (dwBytesPerLine * dwHeight);

  // 24/02/2005 - <maurilio.longo@libero.it>
  // needed to copy bits afterward
  bi.biSizeImage = dwBytesPerLine * dwHeight;

  // alloc memory block to store our bitmap
  hDIB = GlobalAlloc(GHND, dwLen);

  // major bummer if we couldn't get memory block
  if (!hDIB) {
    return nullptr;
  }

  // lock memory and get pointer to it
  lpbi = (LPBITMAPINFOHEADER)GlobalLock(hDIB);

  // use our bitmap info structure to fill in first part of
  // our DIB with the BITMAPINFOHEADER
  *lpbi = bi;

  // Since we don't know what the colortable and bits should contain,
  // just leave these blank.  Unlock the DIB and return the HDIB.
  GlobalUnlock(hDIB);

  // return handle to the DIB
  return hDIB;
}

#define FI_RGBA_RED_MASK 0x00FF0000
#define FI_RGBA_GREEN_MASK 0x0000FF00
#define FI_RGBA_BLUE_MASK 0x000000FF

// 24/02/2005 - <maurilio.longo@libero.it>
// Converts a FIBITMAP into a DIB, works OK only for 24bpp images, though
HB_FUNC(FI_FI2DIB)
{
  FIBITMAP *dib = hwg_par_FIBITMAP(1);
  HANDLE hdib;

  pGetwidth = (FREEIMAGE_GETWIDTH)s_getFunction((FARPROC)pGetwidth, "_FreeImage_GetWidth@4");
  pGetheight = (FREEIMAGE_GETHEIGHT)s_getFunction((FARPROC)pGetheight, "_FreeImage_GetHeight@4");
  pGetBPP = (FREEIMAGE_GETBPP)s_getFunction((FARPROC)pGetBPP, "_FreeImage_GetBPP@4");
  pGetPitch = (FREEIMAGE_GETPITCH)s_getFunction((FARPROC)pGetBPP, "_FreeImage_GetPitch@4");
  pGetbits = (FREEIMAGE_GETBITS)s_getFunction((FARPROC)pGetbits, "_FreeImage_GetBits@4");

  hdib = CreateDIB((WORD)pGetwidth(dib), (WORD)pGetheight(dib), (WORD)pGetBPP(dib));

  if (hdib) {
    // int32_t scan_width = pGetPitch(dib); unused
    LPBITMAPINFO lpbi = (LPBITMAPINFO)GlobalLock(hdib);
    memcpy((LPBYTE)((uint8_t *)lpbi) + lpbi->bmiHeader.biSize, pGetbits(dib), lpbi->bmiHeader.biSizeImage);
    GlobalUnlock(hdib);
    hb_retnint((intptr_t)hdib);
  } else {
    hb_retnl(0);
  }
}

// 24/02/2005 - <maurilio.longo@libero.it>
// This comes straight from freeimage fipWinImage::copyToHandle()
static void SET_FREEIMAGE_MARKER(BITMAPINFOHEADER *bmih, FIBITMAP *dib)
{

  pGetImageType = (FREEIMAGE_GETIMAGETYPE)s_getFunction((FARPROC)pGetImageType, "_FreeImage_GetImageType@4");

  // Windows constants goes from 0L to 5L
  // Add 0xFF to avoid conflicts
  bmih->biCompression = 0xFF + pGetImageType(dib);
}

HB_FUNC(FI_FI2DIBEX)
{
  FIBITMAP *_dib = hwg_par_FIBITMAP(1);
  HANDLE hMem = nullptr;

  pGetColorsUsed = (FREEIMAGE_GETCOLORSUSED)s_getFunction((FARPROC)pGetColorsUsed, "_FreeImage_GetColorsUsed@4");
  pGetwidth = (FREEIMAGE_GETWIDTH)s_getFunction((FARPROC)pGetwidth, "_FreeImage_GetWidth@4");
  pGetheight = (FREEIMAGE_GETHEIGHT)s_getFunction((FARPROC)pGetheight, "_FreeImage_GetHeight@4");
  pGetBPP = (FREEIMAGE_GETBPP)s_getFunction((FARPROC)pGetBPP, "_FreeImage_GetBPP@4");
  pGetPitch = (FREEIMAGE_GETPITCH)s_getFunction((FARPROC)pGetPitch, "_FreeImage_GetPitch@4");
  pGetinfoHead = (FREEIMAGE_GETINFOHEADER)s_getFunction((FARPROC)pGetinfoHead, "_FreeImage_GetInfoHeader@4");
  pGetinfo = (FREEIMAGE_GETINFO)s_getFunction((FARPROC)pGetinfo, "_FreeImage_GetInfo@4");
  pGetbits = (FREEIMAGE_GETBITS)s_getFunction((FARPROC)pGetbits, "_FreeImage_GetBits@4");
  pGetPalette = (FREEIMAGE_GETPALETTE)s_getFunction((FARPROC)pGetPalette, "_FreeImage_GetPalette@4");
  pGetImageType = (FREEIMAGE_GETIMAGETYPE)s_getFunction((FARPROC)pGetImageType, "_FreeImage_GetImageType@4");

  if (_dib) {
    // Get equivalent DIB size
    int32_t dib_size = sizeof(BITMAPINFOHEADER);
    uint8_t *dib;
    uint8_t *p_dib, *bits;
    BITMAPINFOHEADER *bih;
    RGBQUAD *pal;

    dib_size += pGetColorsUsed(_dib) * sizeof(RGBQUAD);
    dib_size += pGetPitch(_dib) * pGetheight(_dib);

    // Allocate a DIB
    hMem = GlobalAlloc(GHND, dib_size);
    dib = (uint8_t *)GlobalLock(hMem);

    memset(dib, 0, dib_size);

    p_dib = (uint8_t *)dib;

    // Copy the BITMAPINFOHEADER
    bih = pGetinfoHead(_dib);
    memcpy(p_dib, bih, sizeof(BITMAPINFOHEADER));

    if (pGetImageType(_dib) != 1 /*FIT_BITMAP */) {
      // this hack is used to store the bitmap type in the biCompression member of the BITMAPINFOHEADER
      SET_FREEIMAGE_MARKER((BITMAPINFOHEADER *)p_dib, _dib);
    }
    p_dib += sizeof(BITMAPINFOHEADER);

    // Copy the palette
    pal = pGetPalette(_dib);
    memcpy(p_dib, pal, pGetColorsUsed(_dib) * sizeof(RGBQUAD));
    p_dib += pGetColorsUsed(_dib) * sizeof(RGBQUAD);

    // Copy the bitmap
    bits = pGetbits(_dib);
    memcpy(p_dib, bits, pGetPitch(_dib) * pGetheight(_dib));

    GlobalUnlock(hMem);
  }

  hb_retnint((intptr_t)hMem);
}

HB_FUNC(FI_DRAW)
{
  FIBITMAP *dib = hwg_par_FIBITMAP(1);
  HDC hDC = hwg_par_HDC(2);
  int32_t nWidth = (int32_t)hb_parnl(3), nHeight = (int32_t)hb_parnl(4); // TODO: parnl -> parni
  int32_t nDestWidth, nDestHeight;
  POINT pp[2];
  // char cres[40];
  // BOOL l;

  if (hb_pcount() > 6 && !HB_ISNIL(7)) {
    nDestWidth = hb_parni(7);
    nDestHeight = hb_parni(8);
  } else {
    nDestWidth = nWidth;
    nDestHeight = nHeight;
  }

  pp[0].x = hb_parni(5);
  pp[0].y = hb_parni(6);
  pp[1].x = pp[0].x + nDestWidth;
  pp[1].y = pp[0].y + nDestHeight;
  // sprintf(cres, "\n %d %d %d %d", pp[0].x, pp[0].y, pp[1].x, pp[1].y);
  // writelog(cres);
  // l = DPtoLP(hDC, pp, 2);
  // sprintf(cres, "\n %d %d %d %d %d", pp[0].x, pp[0].y, pp[1].x, pp[1].y, l);
  // writelog(cres);

  pGetbits = (FREEIMAGE_GETBITS)s_getFunction((FARPROC)pGetbits, "_FreeImage_GetBits@4");
  pGetinfo = (FREEIMAGE_GETINFO)s_getFunction((FARPROC)pGetinfo, "_FreeImage_GetInfo@4");

  if (pGetbits && pGetinfo) {
    SetStretchBltMode(hDC, COLORONCOLOR);
    StretchDIBits(hDC, pp[0].x, pp[0].y, pp[1].x - pp[0].x, pp[1].y - pp[0].y, 0, 0, nWidth, nHeight, pGetbits(dib),
                  pGetinfo(dib), DIB_RGB_COLORS, SRCCOPY);
  }
}

HB_FUNC(FI_BMP2FI)
{
  HBITMAP hbmp = hwg_par_HBITMAP(1);

  if (hbmp) {
    FIBITMAP *dib;
    BITMAP bm;

    pAllocate = (FREEIMAGE_ALLOCATE)s_getFunction((FARPROC)pAllocate, "_FreeImage_Allocate@24");
    pGetbits = (FREEIMAGE_GETBITS)s_getFunction((FARPROC)pGetbits, "_FreeImage_GetBits@4");
    pGetinfo = (FREEIMAGE_GETINFO)s_getFunction((FARPROC)pGetinfo, "_FreeImage_GetInfo@4");
    pGetheight = (FREEIMAGE_GETHEIGHT)s_getFunction((FARPROC)pGetheight, "_FreeImage_GetHeight@4");

    if (pAllocate && pGetbits && pGetinfo && pGetheight) {
      HDC hDC = GetDC(nullptr);

      GetObject(hbmp, sizeof(BITMAP), (LPVOID)&bm);
      dib = pAllocate(bm.bmWidth, bm.bmHeight, bm.bmBitsPixel, 0, 0, 0);
      GetDIBits(hDC, hbmp, 0, pGetheight(dib), pGetbits(dib), pGetinfo(dib), DIB_RGB_COLORS);
      ReleaseDC(nullptr, hDC);
      hb_retnint((intptr_t)dib);
      return;
    }
  }
  hb_retnl(0);
}

// Next three from EZTwain.c ( http://www.twain.org )
static int32_t ColorCount(int32_t bpp)
{
  return 0xFFF & (1 << bpp);
}

static int32_t BmiColorCount(LPBITMAPINFOHEADER lpbi)
{
  if (lpbi->biSize == sizeof(BITMAPCOREHEADER)) {
    LPBITMAPCOREHEADER lpbc = ((LPBITMAPCOREHEADER)lpbi);
    return 1 << lpbc->bcBitCount;
  } else if (lpbi->biClrUsed == 0) {
    return ColorCount(lpbi->biBitCount);
  } else {
    return (int32_t)lpbi->biClrUsed;
  }
} // BmiColorCount

static int32_t DibNumColors(VOID FAR *pv)
{
  return BmiColorCount((LPBITMAPINFOHEADER)pv);
} // DibNumColors

static LPBYTE DibBits(LPBITMAPINFOHEADER lpdib)
// Given a pointer to a locked DIB, return a pointer to the actual bits (pixels)
{
  DWORD dwColorTableSize = (DWORD)(DibNumColors(lpdib) * sizeof(RGBQUAD));
  LPBYTE lpBits = (LPBYTE)lpdib + lpdib->biSize + dwColorTableSize;

  return lpBits;
} // end DibBits

// 19/05/2005 - <maurilio.longo@libero.it>
// Convert a windows DIB into a FIBITMAP
HB_FUNC(FI_DIB2FI)
{
  HANDLE hdib = (HANDLE)(intptr_t)hb_parnl(1);
  int32_t i;

  if (hdib) {
    FIBITMAP *dib;
    LPBITMAPINFOHEADER lpbi = (LPBITMAPINFOHEADER)GlobalLock(hdib);

    pConvertFromRawBits =
        (FREEIMAGE_CONVERTFROMRAWBITS)s_getFunction((FARPROC)pConvertFromRawBits, "_FreeImage_ConvertFromRawBits@36");
    pGetPalette = (FREEIMAGE_GETPALETTE)s_getFunction((FARPROC)pGetPalette, "_FreeImage_GetPalette@4");
    pGetBPP = (FREEIMAGE_GETBPP)s_getFunction((FARPROC)pGetBPP, "_FreeImage_GetBPP@4");

    if (pConvertFromRawBits && lpbi) {
      // int32_t pitch = ((((lpbi->biWidth * lpbi->biBitCount) + 31) &~31) >> 3);
      int32_t pitch = ((((lpbi->biBitCount * lpbi->biWidth) + 31) / 32) * 4);

      dib = pConvertFromRawBits(DibBits(lpbi), lpbi->biWidth, lpbi->biHeight, pitch, lpbi->biBitCount, FI_RGBA_RED_MASK,
                                FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, hb_parl(2));

      // I can't print it with FI_DRAW, though, and I don't know why
      if (pGetBPP(dib) <= 8) {
        // Convert palette entries
        RGBQUAD *pal = pGetPalette(dib);
        RGBQUAD *dibpal = (RGBQUAD *)(((LPBYTE)lpbi) + lpbi->biSize);

        for (i = 0; i < BmiColorCount(lpbi); i++) {
          pal[i].rgbRed = dibpal[i].rgbRed;
          pal[i].rgbGreen = dibpal[i].rgbGreen;
          pal[i].rgbBlue = dibpal[i].rgbBlue;
          pal[i].rgbReserved = 0;
        }
      }

      GlobalUnlock(hdib);
      hb_retnint((intptr_t)dib);
      return;
    } else {
      GlobalUnlock(hdib);
    }
  }
  hb_retnl(0);
}

HB_FUNC(FI_RESCALE)
{
  pRescale = (FREEIMAGE_RESCALE)s_getFunction((FARPROC)pRescale, "_FreeImage_Rescale@16");

  hb_retnint((pRescale)
                 ? (intptr_t)pRescale(hwg_par_FIBITMAP(1), hb_parnl(2), hb_parnl(3), (FREE_IMAGE_FILTER)hb_parni(4))
                 : 0);
}

// Channel is an enumerated type from freeimage.h passed as second parameter
HB_FUNC(FI_REMOVECHANNEL)
{
  FIBITMAP *dib = hwg_par_FIBITMAP(1);
  FIBITMAP *dib8;

  pAllocate = (FREEIMAGE_ALLOCATE)s_getFunction((FARPROC)pAllocate, "_FreeImage_Allocate@24");
  pGetwidth = (FREEIMAGE_GETWIDTH)s_getFunction((FARPROC)pGetwidth, "_FreeImage_GetWidth@4");
  pGetheight = (FREEIMAGE_GETHEIGHT)s_getFunction((FARPROC)pGetheight, "_FreeImage_GetHeight@4");
  pSetChannel = (FREEIMAGE_SETCHANNEL)s_getFunction((FARPROC)pSetChannel, "_FreeImage_SetChannel@12");
  pUnload = (FREEIMAGE_UNLOAD)s_getFunction((FARPROC)pUnload, "_FreeImage_Unload@4");

  dib8 = pAllocate(pGetwidth(dib), pGetheight(dib), 8, 0, 0, 0);

  if (dib8) {
    hb_retl(pSetChannel(dib, dib8, (FREE_IMAGE_COLOR_CHANNEL)hb_parni(2)));
    pUnload(dib8);
  } else {
    hb_retl(FALSE);
  }
}

// Set of functions for loading the image from memory

uint32_t DLL_CALLCONV _ReadProc(void *buffer, uint32_t size, uint32_t count, fi_handle handle)
{
  uint8_t *tmp = (uint8_t *)buffer;
  uint32_t u;
  HB_SYMBOL_UNUSED(handle);

  for (u = 0; u < count; u++) {
    memcpy(tmp, g_load_address, size);
    g_load_address = (uint8_t *)g_load_address + size;
    tmp += size;
  }
  return count;
}

uint32_t DLL_CALLCONV _WriteProc(void *buffer, uint32_t size, uint32_t count, fi_handle handle)
{
  HB_SYMBOL_UNUSED(buffer);
  HB_SYMBOL_UNUSED(count);
  HB_SYMBOL_UNUSED(handle);

  return size;
}

int DLL_CALLCONV _SeekProc(fi_handle handle, long offset, int32_t origin)
{
  // assert(origin != SEEK_END);

  g_load_address = ((origin == SEEK_SET) ? (uint8_t *)handle : (uint8_t *)g_load_address) + offset;
  return 0;
}

long DLL_CALLCONV _TellProc(fi_handle handle)
{
  // assert((long int)handle >= (long int)g_load_address);

  return ((long int)(intptr_t)g_load_address - (long int)(intptr_t)handle);
}

HB_FUNC(FI_LOADFROMMEM)
{
  pLoadFromHandle = (FREEIMAGE_LOADFROMHANDLE)s_getFunction((FARPROC)pLoadFromHandle, "_FreeImage_LoadFromHandle@16");

  if (pLoadFromHandle) {
    const char *image = hb_parc(1);
    const char *cType;
    FREE_IMAGE_FORMAT fif;
    FreeImageIO io;

    io.read_proc = _ReadProc;
    io.write_proc = _WriteProc;
    io.tell_proc = _TellProc;
    io.seek_proc = _SeekProc;

    cType = hb_parc(2);
    if (cType) {
      if (!hb_stricmp(cType, "jpg")) {
        fif = FIF_JPEG;
      } else if (!hb_stricmp(cType, "bmp")) {
        fif = FIF_BMP;
      } else if (!hb_stricmp(cType, "png")) {
        fif = FIF_PNG;
      } else if (!hb_stricmp(cType, "tiff")) {
        fif = FIF_TIFF;
      } else {
        fif = FIF_UNKNOWN;
      }
    } else {
      fif = FIF_UNKNOWN;
    }

    g_load_address = (fi_handle)image;
    hb_retnint((intptr_t)pLoadFromHandle(fif, &io, (fi_handle)image, (hb_pcount() > 2) ? hb_parni(3) : 0));
  } else {
    hb_retnl(0);
  }
}

HB_FUNC(FI_ROTATECLASSIC)
{
  pRotateClassic = (FREEIMAGE_ROTATECLASSIC)s_getFunction((FARPROC)pRotateClassic, "_FreeImage_RotateClassic@12");

  hb_retnint((pRotateClassic) ? (intptr_t)pRotateClassic(hwg_par_FIBITMAP(1), hb_parnd(2)) : 0);
}

HB_FUNC(FI_GETDOTSPERMETERX)
{
  pGetDotsPerMeterX =
      (FREEIMAGE_GETDOTSPERMETERX)s_getFunction((FARPROC)pGetDotsPerMeterX, "_FreeImage_GetDotsPerMeterX@4");

  hb_retnl((pGetDotsPerMeterX) ? pGetDotsPerMeterX(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC(FI_GETDOTSPERMETERY)
{
  pGetDotsPerMeterY =
      (FREEIMAGE_GETDOTSPERMETERY)s_getFunction((FARPROC)pGetDotsPerMeterY, "_FreeImage_GetDotsPerMeterY@4");

  hb_retnl((pGetDotsPerMeterY) ? pGetDotsPerMeterY(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC(FI_SETDOTSPERMETERX)
{
  pSetDotsPerMeterX =
      (FREEIMAGE_SETDOTSPERMETERX)s_getFunction((FARPROC)pSetDotsPerMeterX, "_FreeImage_SetDotsPerMeterX@8");

  if (pSetDotsPerMeterX) {
    pSetDotsPerMeterX(hwg_par_FIBITMAP(1), hb_parnl(2));
  }

  hb_ret();
}

HB_FUNC(FI_SETDOTSPERMETERY)
{
  pSetDotsPerMeterY =
      (FREEIMAGE_SETDOTSPERMETERY)s_getFunction((FARPROC)pSetDotsPerMeterY, "_FreeImage_SetDotsPerMeterY@8");

  if (pSetDotsPerMeterY) {
    pSetDotsPerMeterY(hwg_par_FIBITMAP(1), hb_parnl(2));
  }

  hb_ret();
}

HB_FUNC(FI_ALLOCATE)
{
  pAllocate = (FREEIMAGE_ALLOCATE)s_getFunction((FARPROC)pAllocate, "_FreeImage_Allocate@24");

  // X, Y, DEPTH
  hb_retnint((uintptr_t)pAllocate(hb_parnl(1), hb_parnl(2), hb_parnl(3), 0, 0, 0));
}

HB_FUNC(FI_PASTE)
{
  pPaste = (FREEIMAGE_PASTE)s_getFunction((FARPROC)pPaste, "_FreeImage_Paste@20");

  hb_retl(pPaste(hwg_par_FIBITMAP(1), // dest
                 hwg_par_FIBITMAP(2), // src
                 hb_parnl(3),         // top
                 hb_parnl(4),         // left
                 hb_parnl(5)));       // alpha
}

HB_FUNC(FI_COPY)
{
  pCopy = (FREEIMAGE_COPY)s_getFunction((FARPROC)pCopy, "_FreeImage_Copy@20");

  hb_retnint((uintptr_t)pCopy(hwg_par_FIBITMAP(1), // dib
                              hb_parnl(2),         // left
                              hb_parnl(3),         // top
                              hb_parnl(4),         // right
                              hb_parnl(5)));       // bottom
}

// just a test, should receive a RGBQUAD structure, a xharbour array
HB_FUNC(FI_SETBACKGROUNDCOLOR)
{
  RGBQUAD rgbquad = {255, 255, 255, 255};

  pSetBackgroundColor =
      (FREEIMAGE_SETBACKGROUNDCOLOR)s_getFunction((FARPROC)pSetBackgroundColor, "_FreeImage_SetBackgroundColor@8");

  hb_retl(pSetBackgroundColor(hwg_par_FIBITMAP(1), &rgbquad));
}

HB_FUNC(FI_INVERT)
{
  pInvert = (FREEIMAGE_INVERT)s_getFunction((FARPROC)pInvert, "_FreeImage_Invert@4");

  hb_retl(pInvert(hwg_par_FIBITMAP(1)));
}

HB_FUNC(FI_GETBITS)
{
  pGetbits = (FREEIMAGE_GETBITS)s_getFunction((FARPROC)pGetbits, "_FreeImage_GetBits@4");

  hb_retptr(pGetbits(hwg_par_FIBITMAP(1)));
}

HB_FUNC(FI_CONVERTTO8BITS)
{
  pConvertTo8Bits = (FREEIMAGE_CONVERTTO8BITS)s_getFunction((FARPROC)pConvertTo8Bits, "_FreeImage_ConvertTo8Bits@4");

  hb_retnint((intptr_t)pConvertTo8Bits(hwg_par_FIBITMAP(1)));
}

HB_FUNC(FI_CONVERTTOGREYSCALE)
{
  pConvertToGreyscale =
      (FREEIMAGE_CONVERTTOGREYSCALE)s_getFunction((FARPROC)pConvertToGreyscale, "_FreeImage_ConvertToGreyscale@4");

  hb_retnint((intptr_t)pConvertToGreyscale(hwg_par_FIBITMAP(1)));
}

HB_FUNC(FI_THRESHOLD)
{
  pThreshold = (FREEIMAGE_THRESHOLD)s_getFunction((FARPROC)pThreshold, "_FreeImage_Threshold@8");

  hb_retnint((intptr_t)pThreshold(hwg_par_FIBITMAP(1), (uint8_t)hb_parnl(2)));
}

HB_FUNC(FI_FLIPVERTICAL)
{
  pFlipVertical = (FREEIMAGE_FLIPVERTICAL)s_getFunction((FARPROC)pFlipVertical, "_FreeImage_FlipVertical@4");

  hb_retl(pFlipVertical(hwg_par_FIBITMAP(1)));
}

HB_FUNC(FI_GETPIXELINDEX)
{
  uint8_t value = (uint8_t)-1;
  BOOL lRes;
  pGetPixelIndex = (FREEIMAGE_GETPIXELINDEX)s_getFunction((FARPROC)pGetPixelIndex, "_FreeImage_GetPixelIndex@16");

  lRes = pGetPixelIndex(hwg_par_FIBITMAP(1), hb_parni(2), hb_parni(3), &value);

  if (lRes) {
    hb_stornl((uint32_t)value, 4);
  }

  hb_retl(lRes);
}

HB_FUNC(FI_SETPIXELINDEX)
{
  uint8_t value = (uint8_t)hb_parni(4);
  pSetPixelIndex = (FREEIMAGE_SETPIXELINDEX)s_getFunction((FARPROC)pSetPixelIndex, "_FreeImage_SetPixelIndex@16");

  hb_retl(pSetPixelIndex(hwg_par_FIBITMAP(1), hb_parni(2), hb_parni(3), &value));
}

// TODO:
// typedef BOOL (WINAPI *FREEIMAGE_GETPIXELCOLOR)(FIBITMAP *dib, uint32_t x, uint32_t y, RGBQUAD *value);
// typedef BOOL (WINAPI *FREEIMAGE_SETPIXELCOLOR)(FIBITMAP *dib, uint32_t x, uint32_t y, RGBQUAD *value);
