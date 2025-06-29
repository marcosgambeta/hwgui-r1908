//
// Harbour XML Library
// C level XML parse functions
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <stdio.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbapifs.h>
#if defined(__XHARBOUR__)
#include <hbfast.h>
#else
#include <hbapicls.h>
#endif
#include "guilib.h"

#if (defined(_MSC_VER) && (_MSC_VER >= 1400))
#define sscanf sscanf_s
#endif

#define HB_SKIPTABSPACES(sptr)                                                                                         \
  while (*sptr == ' ' || *sptr == '\t' || *sptr == '\r' || *sptr == '\n')                                              \
  (sptr)++
#define HB_SKIPCHARS(sptr)                                                                                             \
  while (*sptr && *sptr != ' ' && *sptr != '\t' && *sptr != '=' && *sptr != '>' && *sptr != '<' && *sptr != '\"' &&    \
         *sptr != '\'' && *sptr != '\r' && *sptr != '\n')                                                              \
  (sptr)++

#define HBXML_ERROR_NOT_LT 1
#define HBXML_ERROR_NOT_GT 2
#define HBXML_ERROR_WRONG_TAG_END 3
#define HBXML_ERROR_WRONG_END 4
#define HBXML_ERROR_WRONG_ENTITY 5
#define HBXML_ERROR_NOT_QUOTE 6
#define HBXML_ERROR_TERMINATION 7

#define HBXML_TYPE_TAG 0
#define HBXML_TYPE_SINGLE 1
#define HBXML_TYPE_COMMENT 2
#define HBXML_TYPE_CDATA 3
#define HBXML_TYPE_PI 4

static unsigned char *cBuffer;
static int nParseError;
static HB_ULONG ulOffset;

#define HBXML_PREDEFS_KOL 6
static unsigned char *predefinedEntity1[] = {(unsigned char *)"lt;",   (unsigned char *)"gt;",
                                             (unsigned char *)"amp;",  (unsigned char *)"quot;",
                                             (unsigned char *)"apos;", (unsigned char *)"nbsp;"};
static unsigned char *predefinedEntity2 = (unsigned char *)"<>&\"\' ";

void hbxml_error(int nError, unsigned char *ptr)
{
  nParseError = nError;
  ulOffset = (HB_ULONG)(ptr - cBuffer);
}

HB_FUNC(HBXML_TRANSFORM)
{
  PHB_ITEM pItem;
  unsigned char *pBuffer = (unsigned char *)hb_parc(1), *pNew;
  unsigned char *ptr, *ptr1, *ptrs, c;
  HB_ULONG ulLen = (HB_ULONG)hb_parclen(1);
  int iLenAdd = 0, iLen;

  ptr = pBuffer;
  while ((c = *ptr) != 0)
  {
    for (ptrs = predefinedEntity2; *ptrs; ptrs++)
    {
      if (*ptrs == c)
      {
        iLenAdd += (int)strlen((char *)predefinedEntity1[ptrs - predefinedEntity2]);
        break;
      }
    }
    ptr++;
  }
  if (iLenAdd)
  {
    pNew = (unsigned char *)hb_xgrab(ulLen + iLenAdd + 1);
    ptr = pBuffer;
    ptr1 = pNew;
    while ((c = *ptr) != 0)
    {
      *ptr1 = *ptr;
      for (ptrs = predefinedEntity2; *ptrs; ptrs++)
      {
        if (*ptrs == c)
        {
          iLen = (int)strlen((char *)predefinedEntity1[ptrs - predefinedEntity2]);
          *ptr1++ = '&';
          memcpy(ptr1, predefinedEntity1[ptrs - predefinedEntity2], iLen);
          ptr1 += iLen - 1;
          break;
        }
      }
      ptr++;
      ptr1++;
    }
    *ptr1 = '\0';
    pItem = hb_itemPutCLPtr(HWG_NULLPTR, (char *)pNew, ulLen + iLenAdd);
  }
  else
  {
    pItem = hb_itemPutCL(HWG_NULLPTR, (char *)pBuffer, ulLen);
  }
  hb_itemReturnRelease(pItem);
}

/*
 * hbxml_pp(unsigned char * ptr, HB_ULONG ulLen)
 * Translation of the predefined entities ( &lt;, etc. )
 */
PHB_ITEM hbxml_pp(unsigned char *ptr, HB_ULONG ulLen)
{
  unsigned char *ptrStart = ptr;
  int i, nlen;
  HB_ULONG ul = 0, ul1;

  while (ul < ulLen)
  {
    if (*ptr == '&')
    {
      if (*(ptr + 1) == '#')
      {
        int iChar;
        sscanf((char *)ptr + 2, "%d", &iChar);
        *ptr = (unsigned char)iChar;
        i = 1;
        while (*(ptr + i + 1) >= '0' && *(ptr + i + 1) <= '9')
        {
          i++;
        }
        if (*(ptr + i + 1) == ';')
        {
          i++;
        }
        ulLen -= i;
        for (ul1 = ul + 1; ul1 < ulLen; ul1++)
        {
          *(ptrStart + ul1) = *(ptrStart + ul1 + i);
        }
      }
      else
      {
        for (i = 0; i < HBXML_PREDEFS_KOL; i++)
        {
          nlen = (int)strlen((char *)predefinedEntity1[i]);
          if (!memcmp(ptr + 1, predefinedEntity1[i], nlen))
          {
            *ptr = predefinedEntity2[i];
            ulLen -= nlen;
            for (ul1 = ul + 1; ul1 < ulLen; ul1++)
            {
              *(ptrStart + ul1) = *(ptrStart + ul1 + nlen);
            }
            break;
          }
        }
        if (i == HBXML_PREDEFS_KOL)
        {
          hbxml_error(HBXML_ERROR_WRONG_ENTITY, ptr);
        }
      }
    }
    ptr++;
    ul++;
  }
  ptr = ptrStart;
  HB_SKIPTABSPACES(ptr);
  ulLen -= (HB_ULONG)(ptr - ptrStart);
  if (!ulLen)
  {
    return hb_itemPutC(HWG_NULLPTR, "");
  }
  ptrStart = ptr;
  ptr = ptrStart + ulLen - 1;
  while (*ptr == ' ' || *ptr == '\t' || *ptr == '\r' || *ptr == '\n')
  {
    ptr--;
    ulLen--;
  }
  return hb_itemPutCL(HWG_NULLPTR, (char *)ptrStart, ulLen);
}

PHB_ITEM hbxml_getattr(unsigned char **pBuffer, HB_BOOL *lSingle)
{

  unsigned char *ptr, cQuo;
  int nlen;
  PHB_ITEM pArray = hb_itemNew(HWG_NULLPTR);
  PHB_ITEM pSubArray = HWG_NULLPTR;
  PHB_ITEM pTemp;
  HB_BOOL bPI = 0;

  hb_arrayNew(pArray, 0);
  *lSingle = HB_FALSE;
  if (**pBuffer == '<')
  {
    (*pBuffer)++;
    if (**pBuffer == '?')
    {
      bPI = 1;
    }
    HB_SKIPTABSPACES(*pBuffer); // go till tag name
    HB_SKIPCHARS(*pBuffer);     // skip tag name
    if (*(*pBuffer - 1) == '/' || *(*pBuffer - 1) == '?')
    {
      (*pBuffer)--;
    }
    else
    {
      HB_SKIPTABSPACES(*pBuffer);
    }

    while (**pBuffer && **pBuffer != '>')
    {
      if (!(**pBuffer))
      {
        hbxml_error(HBXML_ERROR_TERMINATION, *pBuffer);
        break;
      }
      if (**pBuffer == '/' || **pBuffer == '?')
      {
        *lSingle = (**pBuffer == '/') ? 1 : 2;
        (*pBuffer)++;
        if (**pBuffer != '>' || (*lSingle == 2 && !bPI))
        {
          hbxml_error(HBXML_ERROR_NOT_GT, *pBuffer);
        }
        break;
      }
      ptr = *pBuffer;
      HB_SKIPCHARS(*pBuffer); // skip attribute name
      nlen = (int)(*pBuffer - ptr);
      // add attribute name to result array
      pSubArray = hb_itemNew(HWG_NULLPTR);
      hb_arrayNew(pSubArray, 2);
      pTemp = hb_itemPutCL(HWG_NULLPTR, (char *)ptr, nlen);
      hb_arraySet(pSubArray, 1, pTemp);
      hb_itemRelease(pTemp);

      HB_SKIPTABSPACES(*pBuffer); // go till '='
      if (**pBuffer == '=')
      {
        (*pBuffer)++;
        HB_SKIPTABSPACES(*pBuffer); // go till attribute value
        cQuo = **pBuffer;
        if (cQuo == '\"' || cQuo == '\'')
        {
          (*pBuffer)++;
        }
        else
        {
          hbxml_error(HBXML_ERROR_NOT_QUOTE, *pBuffer);
          break;
        }
        ptr = *pBuffer;
        while (**pBuffer && **pBuffer != cQuo)
        {
          (*pBuffer)++;
        }
        if (**pBuffer != cQuo)
        {
          hbxml_error(HBXML_ERROR_NOT_QUOTE, *pBuffer);
          break;
        }
        nlen = (int)(*pBuffer - ptr);
        // add attribute value to result array
        pTemp = hbxml_pp(ptr, nlen);
        hb_arraySet(pSubArray, 2, pTemp);
        hb_itemRelease(pTemp);
        (*pBuffer)++;
      }
      hb_arrayAdd(pArray, pSubArray);
      hb_itemRelease(pSubArray);
      HB_SKIPTABSPACES(*pBuffer);
    }
    if (nParseError)
    {
      hb_itemRelease(pSubArray);
      hb_itemRelease(pArray);
      return HWG_NULLPTR;
    }
    if (**pBuffer == '>')
    {
      (*pBuffer)++;
    }
  }
  return pArray;
}

void hbxml_getdoctype(PHB_ITEM pDoc, unsigned char **pBuffer)
{
  HB_SYMBOL_UNUSED(pDoc);
  while (**pBuffer != '>')
  {
    (*pBuffer)++;
  }
  (*pBuffer)++;
}

PHB_ITEM hbxml_addnode(PHB_ITEM pParent)
{
  PHB_ITEM pNode = hb_itemNew(HWG_NULLPTR);
  PHB_DYNS pSym = hb_dynsymGet("HXMLNODE");

  hb_vmPushSymbol(hb_dynsymSymbol(pSym));
  hb_vmPushNil();
  hb_vmDo(0);

  hb_objSendMsg(hb_param(-1, HB_IT_ANY), "NEW", 0);
  hb_itemCopy(pNode, hb_param(-1, HB_IT_ANY));

  hb_objSendMsg(pParent, "AITEMS", 0);
  hb_arrayAdd(hb_param(-1, HB_IT_ANY), pNode);

  return pNode;
}

HB_BOOL hbxml_readComment(PHB_ITEM pParent, unsigned char **pBuffer)
{
  unsigned char *ptr;
  PHB_ITEM pNode = hbxml_addnode(pParent);
  PHB_ITEM pTemp;

  pTemp = hb_itemPutNI(HWG_NULLPTR, HBXML_TYPE_COMMENT);
  hb_objSendMsg(pNode, "_TYPE", 1, pTemp);
  hb_itemRelease(pTemp);

  (*pBuffer) += 4;
  ptr = *pBuffer;
  while (**pBuffer && (**pBuffer != '-' || *(*pBuffer + 1) != '-' || *(*pBuffer + 2) != '>'))
  {
    (*pBuffer)++;
  }

  if (**pBuffer)
  {
    pTemp = hb_itemPutCL(HWG_NULLPTR, (char *)ptr, *pBuffer - ptr);
    hb_objSendMsg(pNode, "AITEMS", 0);
    hb_arrayAdd(hb_param(-1, HB_IT_ANY), pTemp);
    hb_itemRelease(pTemp);

    (*pBuffer) += 3;
  }
  else
  {
    hbxml_error(HBXML_ERROR_TERMINATION, *pBuffer);
  }

  hb_itemRelease(pNode);
  return (nParseError) ? HB_FALSE : HB_TRUE;
}

HB_BOOL hbxml_readCDATA(PHB_ITEM pParent, unsigned char **pBuffer)
{
  unsigned char *ptr;
  PHB_ITEM pNode = hbxml_addnode(pParent);
  PHB_ITEM pTemp;

  pTemp = hb_itemPutNI(HWG_NULLPTR, HBXML_TYPE_CDATA);
  hb_objSendMsg(pNode, "_TYPE", 1, pTemp);
  hb_itemRelease(pTemp);

  (*pBuffer) += 9;
  ptr = *pBuffer;
  while (**pBuffer && (**pBuffer != ']' || *(*pBuffer + 1) != ']' || *(*pBuffer + 2) != '>'))
  {
    (*pBuffer)++;
  }

  if (**pBuffer)
  {
    pTemp = hb_itemPutCL(HWG_NULLPTR, (char *)ptr, *pBuffer - ptr);
    hb_objSendMsg(pNode, "AITEMS", 0);
    hb_arrayAdd(hb_param(-1, HB_IT_ANY), pTemp);
    hb_itemRelease(pTemp);

    (*pBuffer) += 3;
  }
  else
  {
    hbxml_error(HBXML_ERROR_TERMINATION, *pBuffer);
  }

  hb_itemRelease(pNode);
  return (nParseError) ? HB_FALSE : HB_TRUE;
}

HB_BOOL hbxml_readElement(PHB_ITEM pParent, unsigned char **pBuffer)
{
  PHB_ITEM pNode = hbxml_addnode(pParent);
  PHB_ITEM pArray;
  unsigned char *ptr, cNodeName[50];
  PHB_ITEM pTemp;
  int nLenNodeName;
  HB_BOOL lEmpty;
  HB_BOOL lSingle;

  (*pBuffer)++;
  if (**pBuffer == '?')
  {
    (*pBuffer)++;
  }
  ptr = *pBuffer;
  HB_SKIPCHARS(ptr);
  nLenNodeName = (int)(ptr - *pBuffer - ((*(ptr - 1) == '/') ? 1 : 0));
  memcpy(cNodeName, *pBuffer, nLenNodeName);
  cNodeName[nLenNodeName] = '\0';

  pTemp = hb_itemPutC(HWG_NULLPTR, (char *)cNodeName);
  hb_objSendMsg(pNode, "_TITLE", 1, pTemp);
  hb_itemRelease(pTemp);

  (*pBuffer)--;
  if (**pBuffer == '?')
  {
    (*pBuffer)--;
  }
  if ((pArray = hbxml_getattr(pBuffer, &lSingle)) == HWG_NULLPTR || nParseError)
  {
    hb_itemRelease(pNode);
    return HB_FALSE;
  }
  else
  {
    hb_objSendMsg(pNode, "_AATTR", 1, pArray);
    hb_itemRelease(pArray);
  }
  pTemp = hb_itemPutNI(HWG_NULLPTR, (lSingle) ? ((lSingle == 2) ? HBXML_TYPE_PI : HBXML_TYPE_SINGLE) : HBXML_TYPE_TAG);
  hb_objSendMsg(pNode, "_TYPE", 1, pTemp);
  hb_itemRelease(pTemp);

  if (!lSingle)
  {
    while (HB_TRUE)
    {
      ptr = *pBuffer;
      lEmpty = HB_TRUE;
      while (**pBuffer != '<')
      {
        if (lEmpty && (**pBuffer != ' ' && **pBuffer != '\t' && **pBuffer != '\r' && **pBuffer != '\n'))
        {
          lEmpty = HB_FALSE;
        }
        (*pBuffer)++;
      }
      if (!lEmpty)
      {
        pTemp = hbxml_pp(ptr, (HB_ULONG)(*pBuffer - ptr));
        hb_objSendMsg(pNode, "AITEMS", 0);
        hb_arrayAdd(hb_param(-1, HB_IT_ANY), pTemp);
        hb_itemRelease(pTemp);
        if (nParseError)
        {
          hb_itemRelease(pNode);
          return HB_FALSE;
        }
      }

      if (*(*pBuffer + 1) == '/')
      {
        if (memcmp(*pBuffer + 2, cNodeName, nLenNodeName))
        {
          hbxml_error(HBXML_ERROR_WRONG_TAG_END, *pBuffer);
          hb_itemRelease(pNode);
          return HB_FALSE;
        }
        else
        {
          while (**pBuffer != '>')
          {
            (*pBuffer)++;
          }
          (*pBuffer)++;
          break;
        }
      }
      else
      {
        if (!memcmp(*pBuffer + 1, "!--", 3))
        {
          if (!hbxml_readComment(pNode, pBuffer))
          {
            hb_itemRelease(pNode);
            return HB_FALSE;
          }
        }
        else if (!memcmp(*pBuffer + 1, "![CDATA[", 8))
        {
          if (!hbxml_readCDATA(pNode, pBuffer))
          {
            hb_itemRelease(pNode);
            return HB_FALSE;
          }
        }
        else
        {
          if (!hbxml_readElement(pNode, pBuffer))
          {
            hb_itemRelease(pNode);
            return HB_FALSE;
          }
        }
      }
    }
  }
  hb_itemRelease(pNode);
  return HB_TRUE;
}

/*
 * hbxml_Getdoc(PHB_ITEM pDoc, char * cData || HB_FHANDLE handle)
 */

HB_FUNC(HBXML_GETDOC)
{
  PHB_ITEM pDoc = hb_param(1, HB_IT_OBJECT);
  HB_BOOL bFile;
  unsigned char *ptr;
  int iMainTags = 0;

  if (HB_ISCHAR(2))
  {
    cBuffer = (unsigned char *)hb_parc(2);
    bFile = HB_FALSE;
  }
  else if (HB_ISNUM(2))
  {
    HB_FHANDLE hInput = (HB_FHANDLE)hb_parnint(2);
    HB_ULONG ulLen = hb_fsSeek(hInput, 0, FS_END), ulRead;

    hb_fsSeek(hInput, 0, FS_SET);
    cBuffer = (unsigned char *)hb_xgrab(ulLen + 1);
    ulRead = (HB_ULONG)hb_fsReadLarge(hInput, (HB_BYTE *)cBuffer, ulLen);
    cBuffer[ulRead] = '\0';
    bFile = HB_TRUE;
  }
  else
  {
    return;
  }

  nParseError = 0;
  ptr = cBuffer;
  HB_SKIPTABSPACES(ptr);
  if (*ptr != '<')
  {
    hbxml_error(HBXML_ERROR_NOT_LT, ptr);
  }
  else
  {
    if (!memcmp(ptr + 1, "?xml", 4))
    {
      HB_BOOL lSingle;
      PHB_ITEM pArray = hbxml_getattr(&ptr, &lSingle);
      if (!pArray || nParseError)
      {
        if (bFile)
        {
          hb_xfree(cBuffer);
        }
        if (pArray)
        {
          hb_itemRelease(pArray);
        }
        hb_retni(nParseError);
        return;
      }
      hb_objSendMsg(pDoc, "_AATTR", 1, pArray);
      hb_itemRelease(pArray);
      HB_SKIPTABSPACES(ptr);
    }
    if (!memcmp(ptr + 1, "!DOCTYPE", 8))
    {
      hbxml_getdoctype(pDoc, &ptr);
      HB_SKIPTABSPACES(ptr);
    }
    while (HB_TRUE)
    {
      if (!memcmp(ptr + 1, "!--", 3))
      {
        if (!hbxml_readComment(pDoc, &ptr))
        {
          break;
        }
      }
      else
      {
        if (iMainTags)
        {
          hbxml_error(HBXML_ERROR_WRONG_END, ptr);
        }
        if (!hbxml_readElement(pDoc, &ptr))
        {
          break;
        }
        iMainTags++;
      }
      HB_SKIPTABSPACES(ptr);
      if (!*ptr)
      {
        break;
      }
    }
  }

  if (bFile)
  {
    hb_xfree(cBuffer);
  }

  hb_retni(nParseError);
}
