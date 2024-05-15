class ZCL_ZFAC_FINANCIALS_PO_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  types:
      ACCOUNTKEY type FDC_S_ACCOUNT_KEY .
  types:
   begin of ts_text_element,
      artifact_name  type c length 40,       " technical name
      artifact_type  type c length 4,
      parent_artifact_name type c length 40, " technical name
      parent_artifact_type type c length 4,
      text_symbol    type textpoolky,
   end of ts_text_element .
  types:
         tt_text_elements type standard table of ts_text_element with key text_symbol .
  types:
      ACCTGDOCHDRBSITEM type FAC_S_ACCDOC_BS_ITM_ODATA .
  types:
      ACCTGDOCHDRBANKCHARGES type FAC_S_ACCDOC_ITM_ODATA .
  types:
      ACCTGDOCHDRLBITEM type FAC_S_ACCDOC_LB_ITM_ODATA .
  types:
      ACCTGDOCHDRPAYMENT type FAC_S_ACCDOC_ITM_ODATA .
  types:
      ACCTGDOCHDRPAYMENTADVICE type FAC_S_ACCDOC_ADVICE_ODATA .
  types:
      ACCTGDOCKEY type FDC_S_ACCDOC_HDR_KEY .
  types:
      ACCTGDOCRESIDUALITEM type FAC_S_ACCDOC_RESIDUAL .
  types:
      ACCTGDOCSIMTMPKEY type FDC_S_ACCDOC_SIM_TMP_KEY .
  types:
      ACCTGDOCTMPKEY type FDC_S_ACCDOC_HDR_TMP_KEY .
  types:
    begin of CREATECLEARINGFOROPENITEMRETUR,
        TMPTY type C length 1,
        TMPID type C length 22,
        HOLDDOCUMENTGUID type SYSUUID_X,
    end of CREATECLEARINGFOROPENITEMRETUR .
  types:
      FILESHARE4JOURNALENTRIES type FAC_S_ACCDOC_FILE_SHARE .
  types:
      FUNCTIONIMPORTDUMMYRETURN type FAC_S_DUMMY .
  types:
      FUNCTIONIMPORTRETMODIFYDISPUTE type FAC_S_FUNC_IMP_RET_MOD_DISPUTE .
  types:
      FUNCTIONIMPORTSUCCESS type FAC_S_ACTION_RETURN .
  types:
      HOLDDOCKEY type FDC_S_HOLDDOC_KEY .
  types:
    begin of HOLDDOCUMENTCOUNT,
        HEADERCOUNT type I,
        ITEMCOUNT type I,
    end of HOLDDOCUMENTCOUNT .
  types:
    begin of HOLDDOCUMENTPARKRETURN,
        NO_DOC_WITH_ERRORS type P length 3 decimals 0,
        NO_DOC_WITH_WARNINGS type P length 3 decimals 0,
        NO_PARKED type P length 3 decimals 0,
    end of HOLDDOCUMENTPARKRETURN .
  types:
    begin of HOLDDOCUMENTPOSTRETURN,
        NO_DOC_WITH_ERRORS type P length 3 decimals 0,
        NO_DOC_WITH_WARNINGS type P length 3 decimals 0,
        NO_POSTED type P length 3 decimals 0,
    end of HOLDDOCUMENTPOSTRETURN .
  types:
      OPENITEMREFERENCE type FAC_S_OPEN_ITEM_REFERENCE .
  types:
    begin of SAP__FITTOPAGE,
        ERRORRECOVERYBEHAVIOR type C length 8,
        ISENABLED type FLAG,
        MINIMUMFONTSIZE type I,
    end of SAP__FITTOPAGE .
  types:
      WORKFLOWSTATUS type FAC_S_WORKFLOW_STATUS .
  types:
    begin of TS_RECURRINGACCOUNTINGDOCUMENT,
        FISCALYEAR type C length 4,
        COMPANYCODE type C length 4,
        ACCOUNTINGDOCUMENT type C length 10,
    end of TS_RECURRINGACCOUNTINGDOCUMENT .
  types:
    begin of TS_MODIFYDISPUTES,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_MODIFYDISPUTES .
  types:
    begin of TS_BANKSTATEMENTPOSTAREA1,
        BANKSTATEMENTITEM type C length 5,
        BANKSTATEMENTSHORTID type C length 8,
    end of TS_BANKSTATEMENTPOSTAREA1 .
  types:
    begin of TS_RECURRINGACCOUNTINGDOCUMEN,
        DUEDATE type TIMESTAMP,
        FISCALYEAR type C length 4,
        COMPANYCODE type C length 4,
        ACCOUNTINGDOCUMENT type C length 10,
        XSIMULATION type FLAG,
        POSTINGDATE type TIMESTAMP,
    end of TS_RECURRINGACCOUNTINGDOCUMEN .
  types:
    begin of TS_BANKSTATEMENTCOMPLETE,
        BANKSTATEMENTSHORTID type C length 8,
        BANKSTATEMENTITEM type C length 5,
    end of TS_BANKSTATEMENTCOMPLETE .
  types:
    begin of TS_ACTIVATEITEMSTOBECLEAREDFOR,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_ACTIVATEITEMSTOBECLEAREDFOR .
  types:
    begin of TS_ACTIVATEITEMSTOBECLEARED,
        POSTEDBY type TIMESTAMP,
        LINEITEMTYPE type C length 1,
        UMSKZ type C length 1,
        LDGRP type C length 4,
        FINANCIALACCOUNTTYPE type C length 1,
        COMPANYCODE type C length 4,
        ACCOUNT type C length 10,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_ACTIVATEITEMSTOBECLEARED .
  types:
    begin of TS_DEACTIVATEITEMSTOBECLEARED,
        FINANCIALACCOUNTTYPE type C length 1,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_DEACTIVATEITEMSTOBECLEARED .
  types:
    begin of TS_PARSENOTETOPAYEE,
        TMPID type C length 22,
        TMPTY type C length 1,
    end of TS_PARSENOTETOPAYEE .
  types:
    begin of TS_ITEMCALCULATETAXBASEAMOUNT,
        POSNR type C length 10,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_ITEMCALCULATETAXBASEAMOUNT .
  types:
    begin of TS_CREATECLEARINGFOROPENITEM,
        CLEARINGTRANSACTION type C length 8,
        FINANCIALACCOUNTTYPE type C length 1,
        ACCOUNT type C length 10,
        ACCOUNTINGDOCUMENTITEM type C length 3,
        FISCALYEAR type C length 4,
        COMPANYCODE type C length 4,
        ACCOUNTINGDOCUMENT type C length 10,
    end of TS_CREATECLEARINGFOROPENITEM .
  types:
    begin of TS_BANKSTATEMENTREOPEN,
        BANKSTATEMENTSHORTID type C length 8,
        BANKSTATEMENTITEM type C length 5,
    end of TS_BANKSTATEMENTREOPEN .
  types:
    begin of TS_CREATECLEARINGFROMPARAMETER,
        PARAMGUID type SYSUUID_X,
    end of TS_CREATECLEARINGFROMPARAMETER .
  types:
    begin of TS_PROPOSEPROMISEDITEMS,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_PROPOSEPROMISEDITEMS .
  types:
    begin of TS_RECURRINGACCOUNTINGDOCUME,
        FISCALYEAR type C length 4,
        COMPANYCODE type C length 4,
        ACCOUNTINGDOCUMENT type C length 10,
    end of TS_RECURRINGACCOUNTINGDOCUME .
  types:
    begin of TS_BANKSTATEMENTREVERSEDOCUMEN,
        FISCALPERIOD type C length 3,
        POSTINGDATE type TIMESTAMP,
        REVERSALREASON type C length 2,
        FISCALYEAR type C length 4,
        COMPANYCODE type C length 4,
        ACCOUNTINGDOCUMENT type C length 10,
        BANKSTATEMENTITEM type C length 5,
        BANKSTATEMENTSHORTID type C length 8,
    end of TS_BANKSTATEMENTREVERSEDOCUMEN .
  types:
    begin of TS_SETSCREENVARIANT,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
        SCREENVARIANT type C length 30,
    end of TS_SETSCREENVARIANT .
  types:
    begin of TS_SIMULATE,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
    end of TS_SIMULATE .
  types:
    begin of TS_SWITCHOPENITEMDISPLAYCURREN,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
    end of TS_SWITCHOPENITEMDISPLAYCURREN .
  types:
    begin of TS_HOLDDOCUMENTDELETE,
        HOLDDOCGUID type SYSUUID_X,
    end of TS_HOLDDOCUMENTDELETE .
  types:
    begin of TS_CREATEWITHREFERENCE,
        CPBET type FLAG,
        ACCOUNTINGDOCUMENT type C length 10,
        COMPANYCODE type C length 4,
        FISCALYEAR type C length 4,
        HEADERSETNAME type C length 40,
        XCPHW type FLAG,
        CPSTO type FLAG,
        CPFKB type FLAG,
        CPSEG type FLAG,
    end of TS_CREATEWITHREFERENCE .
  types:
    begin of TS_POST,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
    end of TS_POST .
  types:
    begin of TS_CHECKANDDETERMINE,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
    end of TS_CHECKANDDETERMINE .
  types:
    begin of TS_PROPOSETAXAMOUNTS,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_PROPOSETAXAMOUNTS .
  types:
    begin of TS_DISTRIBUTETAXAMOUNTS,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_DISTRIBUTETAXAMOUNTS .
  types:
    begin of TS_DISTRIBUTETAXAMOUNTSFROMHEA,
        TAXAMOUNTINCOCODECRCY type P length 2 decimals 2,
        TAXAMOUNTINTRANSCRCY type P length 2 decimals 2,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_DISTRIBUTETAXAMOUNTSFROMHEA .
  types:
    begin of TS_HOLDDOCUMENT,
        HOLD_DOC_ID type C length 40,
        XDELETE_SESSION type FLAG,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
    end of TS_HOLDDOCUMENT .
  types:
    begin of TS_HOLDDOCUMENTRESTORE,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
        HOLDDOCGUID type SYSUUID_X,
    end of TS_HOLDDOCUMENTRESTORE .
  types:
    begin of TS_PROFITABILITYSEGMENTOPEN,
        TMPID type C length 22,
        POSNR type C length 10,
        TMPTY type C length 1,
    end of TS_PROFITABILITYSEGMENTOPEN .
  types:
    begin of TS_PROFITABILITYSEGMENTCLOSE,
        TMPID type C length 22,
        POSNR type C length 10,
        TMPTY type C length 1,
    end of TS_PROFITABILITYSEGMENTCLOSE .
  types:
    begin of TS_PROFITABILITYSEGMENTDERIVEA,
        TMPID type C length 22,
        POSNR type C length 10,
        TMPTY type C length 1,
    end of TS_PROFITABILITYSEGMENTDERIVEA .
  types:
    begin of TS_PROFITABILITYSEGMENTDERIVE,
        TMPID type C length 22,
        POSNR type C length 10,
        TMPTY type C length 1,
    end of TS_PROFITABILITYSEGMENTDERIVE .
  types:
    begin of TS_PROFITABILITYSEGMENTDELETE,
        TMPID type C length 22,
        POSNR type C length 10,
        TMPTY type C length 1,
    end of TS_PROFITABILITYSEGMENTDELETE .
  types:
    begin of TS_GETHOLDDOCUMENTITEMCOUNT,
        HOLDDOCUMENTID type string,
    end of TS_GETHOLDDOCUMENTITEMCOUNT .
  types:
    begin of TS_BANKSTATEMENTAPPLYRULE,
        POSTINGRULEUUID type string,
        BANKSTATEMENTITEM type C length 5,
        BANKSTATEMENTSHORTID type C length 8,
    end of TS_BANKSTATEMENTAPPLYRULE .
  types:
    begin of TS_HOLDDOCUMENTPOST,
        GRPID type C length 12,
        IGNOREWARNINGS type FLAG,
        HOLDDOCGUID type SYSUUID_X,
    end of TS_HOLDDOCUMENTPOST .
  types:
    begin of TS_HOLDDOCUMENTPARK,
        GRPID type C length 12,
        IGNOREWARNINGS type FLAG,
        HOLDDOCGUID type SYSUUID_X,
    end of TS_HOLDDOCUMENTPARK .
  types:
    begin of TS_BANKSTATEMENTAPPLYRULEASJOB,
        SAVEWITHOUTPOST type FLAG,
        POSTINGRULEUUID type string,
        BANKSTATEMENTITEM type C length 5,
        BANKSTATEMENTSHORTID type C length 8,
    end of TS_BANKSTATEMENTAPPLYRULEASJOB .
  types:
    begin of TS_PARTNERANDPAYMENTDATAOPEN,
        TMPTY type C length 1,
        TMPID type C length 22,
        POSNR type C length 10,
    end of TS_PARTNERANDPAYMENTDATAOPEN .
  types:
    begin of TS_PARTNERANDPAYMENTDATADELETE,
        TMPTY type C length 1,
        TMPID type C length 22,
        POSNR type C length 10,
    end of TS_PARTNERANDPAYMENTDATADELETE .
  types:
    begin of TS_PARKEDACCOUNTINGDOCUMENTDEL,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_PARKEDACCOUNTINGDOCUMENTDEL .
  types:
    begin of TS_PARKEDACCOUNTINGDOCUMENTREA,
        FISCALYEAR type C length 4,
        COMPANYCODE type C length 4,
        ACCOUNTINGDOCUMENT type C length 10,
    end of TS_PARKEDACCOUNTINGDOCUMENTREA .
  types:
    begin of TS_PARKEDACCOUNTINGDOCUMENTRE,
        ACCOUNTINGDOCUMENT type C length 10,
        COMPANYCODE type C length 4,
        FISCALYEAR type C length 4,
    end of TS_PARKEDACCOUNTINGDOCUMENTRE .
  types:
    begin of TS_CREATEWITHTEMPLATE,
        FINANCIALPOSTINGTEMPLATE type C length 20,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
        APPLICATIONID type C length 20,
    end of TS_CREATEWITHTEMPLATE .
  types:
    begin of TS_PARKASCOMPLETE,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_PARKASCOMPLETE .
  types:
    begin of TS_ACTIVATEITEMSTOBECLEAREDFO,
        AVSID type C length 16,
        TMPID type C length 22,
        TMPIDTYPE type C length 1,
        ACCOUNT type C length 10,
        COMPANYCODE type C length 4,
        FINANCIALACCOUNTTYPE type C length 1,
    end of TS_ACTIVATEITEMSTOBECLEAREDFO .
  types:
    begin of TS_GETVALUEHELPRESULT,
        SHLPNAME type C length 30,
        SHLPKEY type C length 60,
        MAXHIT type I,
        FILTERS type string,
    end of TS_GETVALUEHELPRESULT .
  types:
    begin of TS_ACTIVATEITEMTOBECLEARED,
        FINANCIALACCOUNTTYPE type C length 1,
        ACCOUNT type C length 10,
        AVSPO type C length 5,
        ACCOUNTINGDOCUMENTITEM type C length 3,
        ACCOUNTINGDOCUMENT type C length 10,
        FISCALYEAR type C length 4,
        AVSID type C length 16,
        COMPANYCODE type C length 4,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
    end of TS_ACTIVATEITEMTOBECLEARED .
  types:
    begin of TS_UPLOADSPREADSHEETFROMFILESH,
        RESOURCEID type string,
        REPOSITORYID type C length 100,
    end of TS_UPLOADSPREADSHEETFROMFILESH .
  types:
    begin of TS_DOWNLOADSPREADSHEET2FILESHA,
        FOLDERID type string,
        REPOSITORYID type C length 100,
        MIMETYPE type string,
        FILENAME type string,
        LANGUAGE type C length 2,
    end of TS_DOWNLOADSPREADSHEET2FILESHA .
  types:
    begin of TS_RECURRINGACCOUNTINGDOCUM,
        ACCOUNTINGDOCUMENT type C length 10,
        COMPANYCODE type C length 4,
        FISCALYEAR type C length 4,
    end of TS_RECURRINGACCOUNTINGDOCUM .
  types:
    begin of TS_ITEMPROPOSETAXAMOUNT,
        TMPIDTYPE type C length 1,
        TMPID type C length 22,
        POSNR type C length 10,
    end of TS_ITEMPROPOSETAXAMOUNT .
  types:
    begin of TS_BANKSTATEMENTGETENTITY,
        BANKSTATEMENTITEM type C length 5,
        BANKSTATEMENTSHORTID type C length 8,
    end of TS_BANKSTATEMENTGETENTITY .
  types:
     TS_APAROPENITEM type FAC_S_APAR_OPEN_ITEM_ODATA .
  types:
TT_APAROPENITEM type standard table of TS_APAROPENITEM .
  types:
     TS_APARWORKLIST type FAC_S_APAR_WORKLIST_ODATA .
  types:
TT_APARWORKLIST type standard table of TS_APARWORKLIST .
  types:
     TS_APARWORKLISTITEM type FAC_S_APAR_WORKLIST_ITEM_ODATA .
  types:
TT_APARWORKLISTITEM type standard table of TS_APARWORKLISTITEM .
  types:
     TS_ATTACHMENT type FAC_S_FINDOC_ATTACHMENT .
  types:
TT_ATTACHMENT type standard table of TS_ATTACHMENT .
  types:
     TS_BANKSTATEMENTWORKLISTITEM type FAC_S_BS_ITM_ODATA .
  types:
TT_BANKSTATEMENTWORKLISTITEM type standard table of TS_BANKSTATEMENTWORKLISTITEM .
  types:
  begin of TS_C_FINPOSTINGTEMPLATETYPE,
     FINPOSTINGAPPLICATIONCODE type C length 20,
     FINANCIALPOSTINGTEMPLATE type C length 20,
     FINPOSTINGAPPLICATIONCODENAME type C length 60,
     FINPOSTINGTEMPLATEDESCRIPTION type C length 30,
     FINPOSTINGTEMPLATECATEGORY type C length 10,
     FINPOSTINGTEMPLATEACCESSPOLICY type C length 2,
     FINPOSTGTMPLACCESSPOLICYNAME type C length 60,
     FINPOSTINGTMPLCREATEDBYUSER type C length 12,
     CREATEDBYUSERNAME type C length 80,
     FINPOSTINGTMPLCREATIONDATE type TIMESTAMP,
     FINPOSTINGTMPLCREATIONTIME type T,
     FINPOSTINGTMPLCHANGEDBYUSER type C length 12,
     LASTCHANGEDBYUSERNAME type C length 80,
     FINPOSTINGTMPLLASTCHANGEDATE type TIMESTAMP,
     FINPOSTINGTMPLLASTCHANGETIME type T,
     FINPOSTINGTEMPLATEISPUBLIC type FLAG,
     COMPANYCODE type C length 4,
     FINPOSTGTMPLLASTCHANGEDATETIME type P length 8 decimals 0,
  end of TS_C_FINPOSTINGTEMPLATETYPE .
  types:
TT_C_FINPOSTINGTEMPLATETYPE type standard table of TS_C_FINPOSTINGTEMPLATETYPE .
  types:
  begin of TS_C_GLACCTWTHHOUSEBANKACCTVHT,
     GLACCOUNT type C length 10,
     COMPANYCODE type C length 4,
     HOUSEBANK type C length 5,
     HOUSEBANKACCOUNT type C length 5,
     GLACCOUNTLONGNAME type C length 50,
     GLACCOUNTNAME type C length 20,
     CHARTOFACCOUNTS type C length 4,
  end of TS_C_GLACCTWTHHOUSEBANKACCTVHT .
  types:
TT_C_GLACCTWTHHOUSEBANKACCTVHT type standard table of TS_C_GLACCTWTHHOUSEBANKACCTVHT .
  types:
     TS_DISPUTE type FAC_S_ACCDOC_DISPUTE_ODATA .
  types:
TT_DISPUTE type standard table of TS_DISPUTE .
  types:
  begin of TS_FAC_POST_ALTERNATIVE_GLACCT,
     COUNTRYCHARTOFACCOUNTS type C length 4,
     ALTERNATIVEGLACCOUNTEXTERNAL type C length 10,
     GLACCOUNT type C length 10,
     COMPANYCODE type C length 4,
     GLACCOUNTNAME type C length 20,
     GLACCOUNTLONGNAME type C length 50,
  end of TS_FAC_POST_ALTERNATIVE_GLACCT .
  types:
TT_FAC_POST_ALTERNATIVE_GLACCT type standard table of TS_FAC_POST_ALTERNATIVE_GLACCT .
  types:
  begin of TS_FAC_POST_ALT_GLACCT_SPRAS_V,
     COUNTRYCHARTOFACCOUNTS type C length 4,
     ALTERNATIVEGLACCOUNTEXTERNAL type C length 10,
     GLACCOUNT type C length 10,
     COMPANYCODE type C length 4,
     LANGUAGE type C length 2,
     GLACCOUNTNAME type C length 20,
     GLACCOUNTLONGNAME type C length 50,
  end of TS_FAC_POST_ALT_GLACCT_SPRAS_V .
  types:
TT_FAC_POST_ALT_GLACCT_SPRAS_V type standard table of TS_FAC_POST_ALT_GLACCT_SPRAS_V .
  types:
  begin of TS_FAC_POST_JE_GLACCT_SPRAS_VH,
     COMPANYCODE type C length 4,
     GLACCOUNTEXTERNAL type C length 10,
     LANGUAGE type C length 2,
     GLACCOUNTNAME type C length 20,
     GLACCOUNTLONGNAME type C length 50,
     ALTERNATIVEGLACCOUNT type C length 10,
     CHARTOFACCOUNTS type C length 4,
  end of TS_FAC_POST_JE_GLACCT_SPRAS_VH .
  types:
TT_FAC_POST_JE_GLACCT_SPRAS_VH type standard table of TS_FAC_POST_JE_GLACCT_SPRAS_VH .
  types:
  begin of TS_FAC_POST_JOUR_ENTRY_GLACCT_,
     T_GLACCOUNT type C length 20,
     COMPANYCODE type C length 4,
     GLACCOUNTEXTERNAL type C length 10,
     GLACCOUNTLONGNAME type C length 50,
     ALTERNATIVEGLACCOUNT type C length 10,
     CHARTOFACCOUNTS type C length 4,
  end of TS_FAC_POST_JOUR_ENTRY_GLACCT_ .
  types:
TT_FAC_POST_JOUR_ENTRY_GLACCT_ type standard table of TS_FAC_POST_JOUR_ENTRY_GLACCT_ .
  types:
  begin of TS_FAC_POST_TAX_PAYABLE_GLACCT,
     T_GLACCOUNT type C length 20,
     COMPANYCODE type C length 4,
     GLACCOUNTEXTERNAL type C length 10,
     GLACCOUNTLONGNAME type C length 50,
     ALTERNATIVEGLACCOUNT type C length 10,
     CHARTOFACCOUNTS type C length 4,
  end of TS_FAC_POST_TAX_PAYABLE_GLACCT .
  types:
TT_FAC_POST_TAX_PAYABLE_GLACCT type standard table of TS_FAC_POST_TAX_PAYABLE_GLACCT .
  types:
  begin of TS_FAC_POST_TAX_P_GLACCT_SPRAS,
     COMPANYCODE type C length 4,
     GLACCOUNTEXTERNAL type C length 10,
     LANGUAGE type C length 2,
     GLACCOUNTNAME type C length 20,
     GLACCOUNTLONGNAME type C length 50,
     ALTERNATIVEGLACCOUNT type C length 10,
     CHARTOFACCOUNTS type C length 4,
  end of TS_FAC_POST_TAX_P_GLACCT_SPRAS .
  types:
TT_FAC_POST_TAX_P_GLACCT_SPRAS type standard table of TS_FAC_POST_TAX_P_GLACCT_SPRAS .
  types:
  begin of TS_FILECONTENTFORDOWNLOAD,
     SPRAS type C length 2,
     FILENAME type string,
     MIMETYPE type string,
     ISTEMPLATE type FLAG,
  end of TS_FILECONTENTFORDOWNLOAD .
  types:
TT_FILECONTENTFORDOWNLOAD type standard table of TS_FILECONTENTFORDOWNLOAD .
  types:
  begin of TS_FILECONTENTFORUPLOAD,
     FILENAME type C length 256,
     MIMETYPE type string,
     TMPID type C length 22,
     TMPIDTYPE type C length 1,
     HOLD_DOC_ID type C length 40,
     GRPID type C length 12,
     IS_INITIAL_UPLOAD type FLAG,
     NO_OF_DOC_TO_BE_UPLD type /IWBEP/SB_ODATA_TY_INT2,
     NO_OF_DOC_UPLD type /IWBEP/SB_ODATA_TY_INT2,
     NO_OF_DOC_UPLD_WITH_W type /IWBEP/SB_ODATA_TY_INT2,
     FILECONTENT type X length 256,
  end of TS_FILECONTENTFORUPLOAD .
  types:
TT_FILECONTENTFORUPLOAD type standard table of TS_FILECONTENTFORUPLOAD .
  types:
     TS_FILESHARE type FAC_S_FILESHARE .
  types:
TT_FILESHARE type standard table of TS_FILESHARE .
  types:
     TS_FILESHAREREPOSITORY type FAC_S_FILESHARE_REPOSITORY .
  types:
TT_FILESHAREREPOSITORY type standard table of TS_FILESHAREREPOSITORY .
  types:
     TS_FILESHARERESOURCE type FAC_S_FILESHARE_RESOURCE .
  types:
TT_FILESHARERESOURCE type standard table of TS_FILESHARERESOURCE .
  types:
     TS_FINSPOSTINGAPARITEM type FAC_S_ACCDOC_ITM_ODATA .
  types:
TT_FINSPOSTINGAPARITEM type standard table of TS_FINSPOSTINGAPARITEM .
  types:
     TS_FINSPOSTINGAPARITEMTOBECLRD type FAC_S_ACCDOC_OI_ODATA .
  types:
TT_FINSPOSTINGAPARITEMTOBECLRD type standard table of TS_FINSPOSTINGAPARITEMTOBECLRD .
  types:
     TS_FINSPOSTINGBSITEMDSPHEADER type FAC_S_ACCDOC_BS_ITM_HDR_ODATA .
  types:
TT_FINSPOSTINGBSITEMDSPHEADER type standard table of TS_FINSPOSTINGBSITEMDSPHEADER .
  types:
     TS_FINSPOSTINGBSITEMHEADER type FAC_S_ACCDOC_BS_ITM_HDR_ODATA .
  types:
TT_FINSPOSTINGBSITEMHEADER type standard table of TS_FINSPOSTINGBSITEMHEADER .
  types:
     TS_FINSPOSTINGCLEARINGHEADER type FAC_S_ACCDOC_CLR_HDR_ODATA .
  types:
TT_FINSPOSTINGCLEARINGHEADER type standard table of TS_FINSPOSTINGCLEARINGHEADER .
  types:
     TS_FINSPOSTINGGLHEADER type FAC_S_ACCDOC_HDR_ODATA .
  types:
TT_FINSPOSTINGGLHEADER type standard table of TS_FINSPOSTINGGLHEADER .
  types:
     TS_FINSPOSTINGGLITEM type FAC_S_ACCDOC_ITM_ODATA .
  types:
TT_FINSPOSTINGGLITEM type standard table of TS_FINSPOSTINGGLITEM .
  types:
     TS_FINSPOSTINGGLITEMPROFITBLTY type FAC_S_ACCDOC_ITM_COPA_ODATA .
  types:
TT_FINSPOSTINGGLITEMPROFITBLTY type standard table of TS_FINSPOSTINGGLITEMPROFITBLTY .
  types:
     TS_FINSPOSTINGGLITEMTOBECLRD type FAC_S_ACCDOC_OI_ODATA .
  types:
TT_FINSPOSTINGGLITEMTOBECLRD type standard table of TS_FINSPOSTINGGLITEMTOBECLRD .
  types:
     TS_FINSPOSTINGLBITEMDSPHEADER type FAC_S_ACCDOC_LB_ITM_HDR_ODATA .
  types:
TT_FINSPOSTINGLBITEMDSPHEADER type standard table of TS_FINSPOSTINGLBITEMDSPHEADER .
  types:
     TS_FINSPOSTINGLBITEMHEADER type FAC_S_ACCDOC_LB_ITM_HDR_ODATA .
  types:
TT_FINSPOSTINGLBITEMHEADER type standard table of TS_FINSPOSTINGLBITEMHEADER .
  types:
     TS_FINSPOSTINGPARTNERANDPAYMEN type FAC_S_ACCDOC_ONE_TIMEA_ODATA .
  types:
TT_FINSPOSTINGPARTNERANDPAYMEN type standard table of TS_FINSPOSTINGPARTNERANDPAYMEN .
  types:
     TS_FINSPOSTINGPAYMENTADVICEITE type FAC_S_ACCDOC_PYMT_ADV_ITM .
  types:
TT_FINSPOSTINGPAYMENTADVICEITE type standard table of TS_FINSPOSTINGPAYMENTADVICEITE .
  types:
     TS_FINSPOSTINGPAYMENTADVICESUB type FAC_S_ACCDOC_PYMT_ADV_SUB_ITM .
  types:
TT_FINSPOSTINGPAYMENTADVICESUB type standard table of TS_FINSPOSTINGPAYMENTADVICESUB .
  types:
     TS_FINSPOSTINGPAYMENTCLEARINGH type FAC_S_ACCDOC_CLR_HDR_ODATA .
  types:
TT_FINSPOSTINGPAYMENTCLEARINGH type standard table of TS_FINSPOSTINGPAYMENTCLEARINGH .
  types:
     TS_FINSPOSTINGPAYMENTDIFFERENC type FAC_S_ACCDOC_PAY_DIFF_ODATA .
  types:
TT_FINSPOSTINGPAYMENTDIFFERENC type standard table of TS_FINSPOSTINGPAYMENTDIFFERENC .
  types:
     TS_FINSPOSTINGPAYMENTHEADER type FAC_S_ACCDOC_PAY_HDR_ODATA .
  types:
TT_FINSPOSTINGPAYMENTHEADER type standard table of TS_FINSPOSTINGPAYMENTHEADER .
  types:
     TS_FINSPOSTINGTAX type FAC_S_ACCDOC_TAX_ODATA .
  types:
TT_FINSPOSTINGTAX type standard table of TS_FINSPOSTINGTAX .
  types:
     TS_FINSPOSTINGWITHHOLDINGTAX type FAC_S_ACCDOC_WHTAX_ODATA .
  types:
TT_FINSPOSTINGWITHHOLDINGTAX type standard table of TS_FINSPOSTINGWITHHOLDINGTAX .
  types:
     TS_GLACCOUNTHOUSEBANKACCOUNTWO type FAC_S_GLMC_HBA_ITEM_ODATA .
  types:
TT_GLACCOUNTHOUSEBANKACCOUNTWO type standard table of TS_GLACCOUNTHOUSEBANKACCOUNTWO .
  types:
     TS_GLACCOUNTLEDGERGROUPWORKLIS type FAC_S_GLMC_LG_ITEM_ODATA .
  types:
TT_GLACCOUNTLEDGERGROUPWORKLIS type standard table of TS_GLACCOUNTLEDGERGROUPWORKLIS .
  types:
     TS_GLACCOUNTWORKLISTITEM type FAC_S_GLMC_ITEM_ODATA .
  types:
TT_GLACCOUNTWORKLISTITEM type standard table of TS_GLACCOUNTWORKLISTITEM .
  types:
     TS_GLOPENITEM type FAC_S_GLMC_OPEN_ITEM .
  types:
TT_GLOPENITEM type standard table of TS_GLOPENITEM .
  types:
  begin of TS_GETAPPSETTINGS,
     KEY type INT1,
     MASSAPPLYISENABLED type FLAG,
     ISLOCKBOXAPPLYRULEENABLED type FLAG,
  end of TS_GETAPPSETTINGS .
  types:
TT_GETAPPSETTINGS type standard table of TS_GETAPPSETTINGS .
  types:
     TS_GLOBALIZATIONFIELDDEF type FAC_S_GLO_HD_FLD_DEF .
  types:
TT_GLOBALIZATIONFIELDDEF type standard table of TS_GLOBALIZATIONFIELDDEF .
  types:
     TS_HOLDDOCWORKLISTITEM type FAC_S_DFT_HOLDDOC_WLI_ODATA .
  types:
TT_HOLDDOCWORKLISTITEM type standard table of TS_HOLDDOCWORKLISTITEM .
  types:
  begin of TS_I_ARLOCKBOXTYPE,
     COMPANYCODE type C length 4,
     HOUSEBANK type C length 5,
     HOUSEBANKACCOUNT type C length 5,
     LOCKBOX type C length 7,
  end of TS_I_ARLOCKBOXTYPE .
  types:
TT_I_ARLOCKBOXTYPE type standard table of TS_I_ARLOCKBOXTYPE .
  types:
  begin of TS_I_ARPOSTGRULEPAYTTRANSCATVH,
     PAYMENTTRANSACTIONCATEGORY type C length 4,
     REPROCESSINGRULEAPPLTYPE type C length 1,
     INTERPRETATIONALGORITHM type C length 3,
     PAYMENTFILEALLOCATIONALGORITHM type C length 30,
     PAYMENTTRANSACTIONTEXT type C length 60,
  end of TS_I_ARPOSTGRULEPAYTTRANSCATVH .
  types:
TT_I_ARPOSTGRULEPAYTTRANSCATVH type standard table of TS_I_ARPOSTGRULEPAYTTRANSCATVH .
  types:
  begin of TS_I_ACCOUNTINGDOCUMENTTYPESTD,
     ACCOUNTINGDOCUMENTTYPE type C length 2,
     T_ACCOUNTINGDOCUMENTTYPE type C length 20,
  end of TS_I_ACCOUNTINGDOCUMENTTYPESTD .
  types:
TT_I_ACCOUNTINGDOCUMENTTYPESTD type standard table of TS_I_ACCOUNTINGDOCUMENTTYPESTD .
  types:
  begin of TS_I_ACCOUNTINGDOCUMENTTYPETEX,
     ACCOUNTINGDOCUMENTTYPE type C length 2,
     LANGUAGE type C length 2,
     ACCOUNTINGDOCUMENTTYPENAME type C length 20,
  end of TS_I_ACCOUNTINGDOCUMENTTYPETEX .
  types:
TT_I_ACCOUNTINGDOCUMENTTYPETEX type standard table of TS_I_ACCOUNTINGDOCUMENTTYPETEX .
  types:
  begin of TS_I_ALLOCATIONALGORITHMFXDVAL,
     ALLOCALGORITHMFIXEDVALUETYPE type C length 30,
     LANGUAGE type C length 2,
     ALLOCALGORITHMPARAMFXDVAL type C length 60,
     ALLOCALGORITHMPARAMFXDVALTXT type C length 60,
  end of TS_I_ALLOCATIONALGORITHMFXDVAL .
  types:
TT_I_ALLOCATIONALGORITHMFXDVAL type standard table of TS_I_ALLOCATIONALGORITHMFXDVAL .
  types:
  begin of TS_I_ALLOCATIONALGORITHMFXDVA,
     ALLOCALGORITHMFIXEDVALUETYPE type C length 30,
     ALLOCALGORITHMPARAMFXDVAL type C length 60,
     T_ALLOCALGORITHMPARAMFXDVAL type C length 60,
  end of TS_I_ALLOCATIONALGORITHMFXDVA .
  types:
TT_I_ALLOCATIONALGORITHMFXDVA type standard table of TS_I_ALLOCATIONALGORITHMFXDVA .
  types:
  begin of TS_I_BANKACCOUNTTYPEVHTYPE,
     BANKACCOUNTTYPE type C length 10,
     BANKACCOUNTTYPETEXT type C length 60,
     BANKACCOUNTCONTRACTTYPE type C length 2,
     BANKACCOUNTCONTRACTTYPENAME type C length 60,
  end of TS_I_BANKACCOUNTTYPEVHTYPE .
  types:
TT_I_BANKACCOUNTTYPEVHTYPE type standard table of TS_I_BANKACCOUNTTYPEVHTYPE .
  types:
  begin of TS_I_BANKACCTNUMBERVHTYPE,
     BANKACCOUNTINTERNALID type C length 10,
     BANKACCOUNTNUMBER type C length 40,
     BANKACCOUNTDESCRIPTION type C length 60,
     BANKACCOUNTCURRENCY type C length 5,
     COMPANYCODE type C length 4,
     BANKACCOUNTTYPE type C length 10,
     BANK type C length 15,
     BANKCOUNTRY type C length 3,
     IBAN type C length 34,
     SWIFTCODE type C length 11,
     HOUSEBANK type C length 5,
     HOUSEBANKACCOUNT type C length 5,
  end of TS_I_BANKACCTNUMBERVHTYPE .
  types:
TT_I_BANKACCTNUMBERVHTYPE type standard table of TS_I_BANKACCTNUMBERVHTYPE .
  types:
  begin of TS_I_BANKSTATEMENTVHTYPE,
     BANKSTATEMENT type C length 5,
     BANKSTATEMENTSHORTID type C length 8,
     BANKSTATEMENTINTERNALID type C length 20,
     COMPANYCODE type C length 4,
     BANKSTATEMENTDATE type TIMESTAMP,
     HOUSEBANK type C length 5,
  end of TS_I_BANKSTATEMENTVHTYPE .
  types:
TT_I_BANKSTATEMENTVHTYPE type standard table of TS_I_BANKSTATEMENTVHTYPE .
  types:
  begin of TS_I_BANKSTMNTITEMREPROCESSREA,
     BANKSTMNTITEMREPROCESSREASON type C length 2,
     T_BANKSTMNTITEMREPROCESSREASON type C length 60,
  end of TS_I_BANKSTMNTITEMREPROCESSREA .
  types:
TT_I_BANKSTMNTITEMREPROCESSREA type standard table of TS_I_BANKSTMNTITEMREPROCESSREA .
  types:
  begin of TS_I_BANKSTMNTITMREPROCESSRSNN,
     BANKSTMNTITEMREPROCESSREASON type C length 2,
     LANGUAGE type C length 2,
     BANKSTMNTITEMREPROCESSRSNNAME type C length 60,
  end of TS_I_BANKSTMNTITMREPROCESSRSNN .
  types:
TT_I_BANKSTMNTITMREPROCESSRSNN type standard table of TS_I_BANKSTMNTITMREPROCESSRSNN .
  types:
  begin of TS_I_BUSINESSAREASTDVHTYPE,
     BUSINESSAREA type C length 4,
     T_BUSINESSAREA type C length 30,
  end of TS_I_BUSINESSAREASTDVHTYPE .
  types:
TT_I_BUSINESSAREASTDVHTYPE type standard table of TS_I_BUSINESSAREASTDVHTYPE .
  types:
  begin of TS_I_CHARTOFACCOUNTSSTDVHTYPE,
     CHARTOFACCOUNTS type C length 4,
     T_CHARTOFACCOUNTS type C length 50,
  end of TS_I_CHARTOFACCOUNTSSTDVHTYPE .
  types:
TT_I_CHARTOFACCOUNTSSTDVHTYPE type standard table of TS_I_CHARTOFACCOUNTSSTDVHTYPE .
  types:
  begin of TS_I_COMPANYCODESTDVHTYPE,
     COMPANYCODE type C length 4,
     COMPANYCODENAME type C length 25,
  end of TS_I_COMPANYCODESTDVHTYPE .
  types:
TT_I_COMPANYCODESTDVHTYPE type standard table of TS_I_COMPANYCODESTDVHTYPE .
  types:
  begin of TS_I_COMPANYCODETYPE,
     COMPANYCODE type C length 4,
     COMPANYCODENAME type C length 25,
     CITYNAME type C length 25,
     COUNTRY type C length 3,
     CURRENCY type C length 5,
     LANGUAGE type C length 2,
     CHARTOFACCOUNTS type C length 4,
     FISCALYEARVARIANT type C length 2,
     COMPANY type C length 6,
     CREDITCONTROLAREA type C length 4,
     T_CREDITCONTROLAREA type C length 35,
     COUNTRYCHARTOFACCOUNTS type C length 4,
     FINANCIALMANAGEMENTAREA type C length 4,
     ADDRESSID type C length 10,
     TAXABLEENTITY type C length 4,
     VATREGISTRATION type C length 20,
     EXTENDEDWHLDGTAXISACTIVE type FLAG,
     CONTROLLINGAREA type C length 4,
     T_CONTROLLINGAREA type C length 25,
     FIELDSTATUSVARIANT type C length 4,
     NONTAXABLETRANSACTIONTAXCODE type C length 2,
     DOCDATEISUSEDFORTAXDETN type FLAG,
     TAXRPTGDATEISACTIVE type FLAG,
     CASHDISCOUNTBASEAMTISNETAMT type FLAG,
  end of TS_I_COMPANYCODETYPE .
  types:
TT_I_COMPANYCODETYPE type standard table of TS_I_COMPANYCODETYPE .
  types:
  begin of TS_I_CONTROLLINGAREASTDVHTYPE,
     CONTROLLINGAREA type C length 4,
     CONTROLLINGAREANAME type C length 25,
  end of TS_I_CONTROLLINGAREASTDVHTYPE .
  types:
TT_I_CONTROLLINGAREASTDVHTYPE type standard table of TS_I_CONTROLLINGAREASTDVHTYPE .
  types:
  begin of TS_I_COSTCENTERSTDVHTYPE,
     CONTROLLINGAREA type C length 4,
     COSTCENTER type C length 10,
     T_COSTCENTER type C length 20,
     VALIDITYENDDATE type TIMESTAMP,
     VALIDITYSTARTDATE type TIMESTAMP,
  end of TS_I_COSTCENTERSTDVHTYPE .
  types:
TT_I_COSTCENTERSTDVHTYPE type standard table of TS_I_COSTCENTERSTDVHTYPE .
  types:
  begin of TS_I_CREDITCONTROLAREASTDVHTYP,
     CREDITCONTROLAREA type C length 4,
     T_CREDITCONTROLAREA type C length 35,
  end of TS_I_CREDITCONTROLAREASTDVHTYP .
  types:
TT_I_CREDITCONTROLAREASTDVHTYP type standard table of TS_I_CREDITCONTROLAREASTDVHTYP .
  types:
  begin of TS_I_CUSTOMER_VHTYPE,
     CUSTOMER type C length 10,
     ORGANIZATIONBPNAME1 type C length 35,
     ORGANIZATIONBPNAME2 type C length 35,
     COUNTRY type C length 3,
     CITYNAME type C length 35,
     STREETNAME type C length 35,
     POSTALCODE type C length 10,
     CUSTOMERNAME type C length 80,
     CUSTOMERACCOUNTGROUP type C length 4,
     AUTHORIZATIONGROUP type C length 4,
     ISBUSINESSPURPOSECOMPLETED type C length 1,
     ISCOMPETITOR type FLAG,
     BUSINESSPARTNER type C length 10,
     BUSINESSPARTNERTYPE type C length 4,
  end of TS_I_CUSTOMER_VHTYPE .
  types:
TT_I_CUSTOMER_VHTYPE type standard table of TS_I_CUSTOMER_VHTYPE .
  types:
  begin of TS_I_GLACCOUNTSTDVHTYPE,
     GLACCOUNT type C length 10,
     T_GLACCOUNT type C length 20,
     COMPANYCODE type C length 4,
     GLACCOUNTEXTERNAL type C length 10,
     ALTERNATIVEGLACCOUNT type C length 10,
     CHARTOFACCOUNTS type C length 4,
     GLACCOUNTGROUP type C length 4,
     GLACCOUNTTYPE type C length 1,
     RECONCILIATIONACCOUNTTYPE type C length 1,
  end of TS_I_GLACCOUNTSTDVHTYPE .
  types:
TT_I_GLACCOUNTSTDVHTYPE type standard table of TS_I_GLACCOUNTSTDVHTYPE .
  types:
  begin of TS_I_HOUSEBANKACCOUNTVHTYPE,
     COMPANYCODE type C length 4,
     HOUSEBANK type C length 5,
     HOUSEBANKACCOUNT type C length 5,
     BANKACCOUNTINTERNALID type C length 10,
     BANKACCOUNT type C length 18,
     BANKACCOUNTNUMBER type C length 40,
     BANKACCOUNTCURRENCY type C length 5,
     HOUSEBANKACCOUNTDESCRIPTION type C length 60,
  end of TS_I_HOUSEBANKACCOUNTVHTYPE .
  types:
TT_I_HOUSEBANKACCOUNTVHTYPE type standard table of TS_I_HOUSEBANKACCOUNTVHTYPE .
  types:
  begin of TS_I_HOUSEBANKSTDVHTYPE,
     COMPANYCODE type C length 4,
     HOUSEBANK type C length 5,
     BANKCOUNTRY type C length 3,
     BANKINTERNALID type C length 15,
  end of TS_I_HOUSEBANKSTDVHTYPE .
  types:
TT_I_HOUSEBANKSTDVHTYPE type standard table of TS_I_HOUSEBANKSTDVHTYPE .
  types:
  begin of TS_I_INTERPRETATIONALGORITHMVH,
     INTERPRETATIONALGORITHM type C length 3,
     T_INTERPRETATIONALGORITHM type C length 60,
  end of TS_I_INTERPRETATIONALGORITHMVH .
  types:
TT_I_INTERPRETATIONALGORITHMVH type standard table of TS_I_INTERPRETATIONALGORITHMVH .
  types:
  begin of TS_I_LANGUAGETYPE,
     LANGUAGE type C length 2,
     T_LANGUAGE type C length 16,
     LANGUAGEISOCODE type C length 2,
  end of TS_I_LANGUAGETYPE .
  types:
TT_I_LANGUAGETYPE type standard table of TS_I_LANGUAGETYPE .
  types:
  begin of TS_I_PAYMENTCLEARINGGROUPVHTYP,
     PAYMENTCLEARINGGROUP type C length 8,
     T_PAYMENTCLEARINGGROUP type C length 255,
  end of TS_I_PAYMENTCLEARINGGROUPVHTYP .
  types:
TT_I_PAYMENTCLEARINGGROUPVHTYP type standard table of TS_I_PAYMENTCLEARINGGROUPVHTYP .
  types:
  begin of TS_I_PAYTADVICEACCOUNTTYPESTDV,
     PAYMENTADVICEACCOUNTTYPE type C length 1,
     T_PAYMENTADVICEACCOUNTTYPE type C length 60,
  end of TS_I_PAYTADVICEACCOUNTTYPESTDV .
  types:
TT_I_PAYTADVICEACCOUNTTYPESTDV type standard table of TS_I_PAYTADVICEACCOUNTTYPESTDV .
  types:
  begin of TS_I_PAYTADVICEACCOUNTTYPETEXT,
     PAYMENTADVICEACCOUNTTYPE type C length 1,
     LANGUAGE type C length 2,
     PAYMENTADVICEACCOUNTTYPENAME type C length 60,
  end of TS_I_PAYTADVICEACCOUNTTYPETEXT .
  types:
TT_I_PAYTADVICEACCOUNTTYPETEXT type standard table of TS_I_PAYTADVICEACCOUNTTYPETEXT .
  types:
  begin of TS_I_PAYTFILEALLOCALGORITHMVHT,
     PAYMENTTRANSACTIONCATEGORY type C length 4,
     T_PAYMENTTRANSACTIONCATEGORY type C length 60,
     PAYMENTFILEALLOCATIONALGORITHM type C length 30,
  end of TS_I_PAYTFILEALLOCALGORITHMVHT .
  types:
TT_I_PAYTFILEALLOCALGORITHMVHT type standard table of TS_I_PAYTFILEALLOCALGORITHMVHT .
  types:
  begin of TS_I_SUPPLIER_VHTYPE,
     SUPPLIER type C length 10,
     SUPPLIERNAME type C length 35,
     AUTHORIZATIONGROUP type C length 4,
     SUPPLIERACCOUNTGROUP type C length 4,
     ISBUSINESSPURPOSECOMPLETED type C length 1,
     BUSINESSPARTNER type C length 10,
     BUSINESSPARTNERTYPE type C length 4,
  end of TS_I_SUPPLIER_VHTYPE .
  types:
TT_I_SUPPLIER_VHTYPE type standard table of TS_I_SUPPLIER_VHTYPE .
  types:
  begin of TS_I_TH_BRANCHCODEVHTYPE,
     ACCOUNTTYPE type C length 1,
     BUSINESSPARTNER type C length 10,
     BRANCHCODE type C length 5,
     TH_BRANCHCODEDESCRIPTION type C length 40,
     ISDEFAULTVALUE type C length 1,
  end of TS_I_TH_BRANCHCODEVHTYPE .
  types:
TT_I_TH_BRANCHCODEVHTYPE type standard table of TS_I_TH_BRANCHCODEVHTYPE .
  types:
  begin of TS_LANGUAGE,
     SPRAS type C length 2,
     SPTXT type C length 16,
  end of TS_LANGUAGE .
  types:
TT_LANGUAGE type standard table of TS_LANGUAGE .
  types:
     TS_LOCKBOXWORKLISTITEM type FAC_S_LB_ITM_ODATA .
  types:
TT_LOCKBOXWORKLISTITEM type standard table of TS_LOCKBOXWORKLISTITEM .
  types:
     TS_MDADDRESS type FAC_S_MD_ADDRESS .
  types:
TT_MDADDRESS type standard table of TS_MDADDRESS .
  types:
     TS_NOTE type FAC_S_FINDOC_NOTE .
  types:
TT_NOTE type standard table of TS_NOTE .
  types:
     TS_RECRRGACCTGDOCOCCURRENCE type FAC_S_RJET_POST_LIST_ODATA .
  types:
TT_RECRRGACCTGDOCOCCURRENCE type standard table of TS_RECRRGACCTGDOCOCCURRENCE .
  types:
     TS_RECRRGACCTGDOCWORKLISTITEM type FAC_S_RJET_ITEM_ODATA .
  types:
TT_RECRRGACCTGDOCWORKLISTITEM type standard table of TS_RECRRGACCTGDOCWORKLISTITEM .
  types:
     TS_RECURRENCEDEFINITION type FAC_S_ACCDOC_RECURR_DEF_ODATA .
  types:
TT_RECURRENCEDEFINITION type standard table of TS_RECURRENCEDEFINITION .
  types:
  begin of TS_SAP__COVERPAGE,
     TITLE type string,
     ID type SYSUUID_X,
     NAME type string,
     VALUE type string,
  end of TS_SAP__COVERPAGE .
  types:
TT_SAP__COVERPAGE type standard table of TS_SAP__COVERPAGE .
  types:
  begin of TS_SAP__DOCUMENTDESCRIPTION,
     ID type SYSUUID_X,
     CREATED_BY type string,
     CREATED_AT type TIMESTAMP,
     FILENAME type string,
     TITLE type string,
  end of TS_SAP__DOCUMENTDESCRIPTION .
  types:
TT_SAP__DOCUMENTDESCRIPTION type standard table of TS_SAP__DOCUMENTDESCRIPTION .
  types:
  begin of TS_SAP__FORMAT,
     ID type SYSUUID_X,
     FONTSIZE type I,
     ORIENTATION type C length 10,
     PAPERSIZE type C length 10,
     BORDERSIZE type I,
     MARGINSIZE type I,
     FONTNAME type C length 255,
     FITTOPAGE type SAP__FITTOPAGE,
  end of TS_SAP__FORMAT .
  types:
TT_SAP__FORMAT type standard table of TS_SAP__FORMAT .
  types:
  begin of TS_SAP__PDFSTANDARD,
     ID type SYSUUID_X,
     USEPDFACONFORMANCEVC type C length 1,
     USEPDFACONFORMANCE type FLAG,
     DOENABLEACCESSIBILITYVC type C length 1,
     DOENABLEACCESSIBILITY type FLAG,
  end of TS_SAP__PDFSTANDARD .
  types:
TT_SAP__PDFSTANDARD type standard table of TS_SAP__PDFSTANDARD .
  types:
  begin of TS_SAP__SIGNATURE,
     ID type SYSUUID_X,
     DO_SIGN type FLAG,
     REASON type string,
  end of TS_SAP__SIGNATURE .
  types:
TT_SAP__SIGNATURE type standard table of TS_SAP__SIGNATURE .
  types:
  begin of TS_SAP__TABLECOLUMNS,
     ID type SYSUUID_X,
     NAME type string,
     HEADER type string,
     HORIZONTAL_ALIGNMENT type C length 10,
  end of TS_SAP__TABLECOLUMNS .
  types:
TT_SAP__TABLECOLUMNS type standard table of TS_SAP__TABLECOLUMNS .
  types:
  begin of TS_SAP__VALUEHELP,
     VALUEHELP type string,
     FIELD_VALUE type string,
     DESCRIPTION type string,
  end of TS_SAP__VALUEHELP .
  types:
TT_SAP__VALUEHELP type standard table of TS_SAP__VALUEHELP .
  types:
     TS_SCREENVARIANT type FAC_S_SCRNVAR_ODATA .
  types:
TT_SCREENVARIANT type standard table of TS_SCREENVARIANT .
  types:
     TS_SEARCHHELPFIELD type FAC_S_SH_FIELD .
  types:
TT_SEARCHHELPFIELD type standard table of TS_SEARCHHELPFIELD .
  types:
     TS_UPLOADEDDOCWORKLISTITEM type FAC_S_UPLDDOC_WLI_ODATA .
  types:
TT_UPLOADEDDOCWORKLISTITEM type standard table of TS_UPLOADEDDOCWORKLISTITEM .
  types:
  begin of TS_VHGLACCOUNTFORINPUT,
     EDITLOKKT type string,
     HKONT type C length 10,
     GLACCT type C length 10,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     BUKRS type C length 4,
  end of TS_VHGLACCOUNTFORINPUT .
  types:
TT_VHGLACCOUNTFORINPUT type standard table of TS_VHGLACCOUNTFORINPUT .
  types:
  begin of TS_VHLOCKBOXNUMBER,
     BUKRS type C length 4,
     HBKID type C length 5,
     HOUSEBANKACCOUNT type C length 5,
     LOCKBOX type C length 7,
  end of TS_VHLOCKBOXNUMBER .
  types:
TT_VHLOCKBOXNUMBER type standard table of TS_VHLOCKBOXNUMBER .
  types:
  begin of TS_VL_CH_ANLH,
     BUKRS type C length 4,
     ANLN1 type C length 12,
  end of TS_VL_CH_ANLH .
  types:
TT_VL_CH_ANLH type standard table of TS_VL_CH_ANLH .
  types:
  begin of TS_VL_CH_BALHDR,
     LOGNUMBER type C length 20,
  end of TS_VL_CH_BALHDR .
  types:
TT_VL_CH_BALHDR type standard table of TS_VL_CH_BALHDR .
  types:
  begin of TS_VL_CH_BNKA,
     BANKS type C length 3,
     BANKL type C length 15,
  end of TS_VL_CH_BNKA .
  types:
TT_VL_CH_BNKA type standard table of TS_VL_CH_BNKA .
  types:
  begin of TS_VL_CH_CKPH,
     KSTRG type C length 12,
     DATBI type TIMESTAMP,
  end of TS_VL_CH_CKPH .
  types:
TT_VL_CH_CKPH type standard table of TS_VL_CH_CKPH .
  types:
  begin of TS_VL_CH_DD03L,
     TABNAME type C length 30,
     FIELDNAME type C length 30,
     AS4LOCAL type C length 1,
     AS4VERS type C length 4,
     POSITION type C length 4,
  end of TS_VL_CH_DD03L .
  types:
TT_VL_CH_DD03L type standard table of TS_VL_CH_DD03L .
  types:
  begin of TS_VL_CH_FMFXPO,
     FIPOS type C length 24,
  end of TS_VL_CH_FMFXPO .
  types:
TT_VL_CH_FMFXPO type standard table of TS_VL_CH_FMFXPO .
  types:
  begin of TS_VL_CH_PBUSINESSPLACE,
     BUKRS type C length 4,
     BRANCH type C length 4,
  end of TS_VL_CH_PBUSINESSPLACE .
  types:
TT_VL_CH_PBUSINESSPLACE type standard table of TS_VL_CH_PBUSINESSPLACE .
  types:
  begin of TS_VL_CH_PRPS,
     PSPNR type C length 24,
  end of TS_VL_CH_PRPS .
  types:
TT_VL_CH_PRPS type standard table of TS_VL_CH_PRPS .
  types:
  begin of TS_VL_CH_TBE11,
     APPLK type C length 6,
  end of TS_VL_CH_TBE11 .
  types:
TT_VL_CH_TBE11 type standard table of TS_VL_CH_TBE11 .
  types:
  begin of TS_VL_CT_ADRC,
     ADDRNUMBER type C length 10,
     DATE_FROM type TIMESTAMP,
     NATION type C length 1,
     REMARK type C length 50,
  end of TS_VL_CT_ADRC .
  types:
TT_VL_CT_ADRC type standard table of TS_VL_CT_ADRC .
  types:
  begin of TS_VL_CT_CBPR,
     KOKRS type C length 4,
     PRZNR type C length 12,
     DATBI type TIMESTAMP,
     KTEXT type C length 20,
  end of TS_VL_CT_CBPR .
  types:
TT_VL_CT_CBPR type standard table of TS_VL_CT_CBPR .
  types:
  begin of TS_VL_CT_CEPC,
     PRCTR type C length 10,
     DATBI type TIMESTAMP,
     KOKRS type C length 4,
     KTEXT type C length 20,
  end of TS_VL_CT_CEPC .
  types:
TT_VL_CT_CEPC type standard table of TS_VL_CT_CEPC .
  types:
  begin of TS_VL_CT_CMIS_L_FS,
     FS_ID type C length 15,
     FS_DESC type C length 60,
  end of TS_VL_CT_CMIS_L_FS .
  types:
TT_VL_CT_CMIS_L_FS type standard table of TS_VL_CT_CMIS_L_FS .
  types:
  begin of TS_VL_CT_FAGL_TLDGRP,
     LDGRP type C length 4,
     NAME type C length 50,
  end of TS_VL_CT_FAGL_TLDGRP .
  types:
TT_VL_CT_FAGL_TLDGRP type standard table of TS_VL_CT_FAGL_TLDGRP .
  types:
  begin of TS_VL_CT_FAR_PYMT_CLG_GRP,
     PAYMENTCLEARINGGRPID type C length 8,
     PAYMENTCLEARINGGRPNAME type C length 255,
  end of TS_VL_CT_FAR_PYMT_CLG_GRP .
  types:
TT_VL_CT_FAR_PYMT_CLG_GRP type standard table of TS_VL_CT_FAR_PYMT_CLG_GRP .
  types:
  begin of TS_VL_CT_FCLM_BAM_AC_TYPE,
     ACC_TYPE_ID type C length 10,
     ACC_TYPE_DESC type C length 60,
  end of TS_VL_CT_FCLM_BAM_AC_TYPE .
  types:
TT_VL_CT_FCLM_BAM_AC_TYPE type standard table of TS_VL_CT_FCLM_BAM_AC_TYPE .
  types:
  begin of TS_VL_CT_FCLM_BAM_AMD,
     ACC_ID type C length 10,
     REVISION type C length 4,
     DESCRIPTION type C length 60,
  end of TS_VL_CT_FCLM_BAM_AMD .
  types:
TT_VL_CT_FCLM_BAM_AMD type standard table of TS_VL_CT_FCLM_BAM_AMD .
  types:
  begin of TS_VL_CT_FEB_REPRO_RRC,
     REPROCREASONCODE type C length 2,
     RRC_TEXT type C length 60,
  end of TS_VL_CT_FEB_REPRO_RRC .
  types:
TT_VL_CT_FEB_REPRO_RRC type standard table of TS_VL_CT_FEB_REPRO_RRC .
  types:
  begin of TS_VL_CT_FINSC_CURTYPE,
     CURTYPE type C length 2,
     NAME type C length 60,
  end of TS_VL_CT_FINSC_CURTYPE .
  types:
TT_VL_CT_FINSC_CURTYPE type standard table of TS_VL_CT_FINSC_CURTYPE .
  types:
  begin of TS_VL_CT_J_1ADTYP,
     BUKRS type C length 4,
     J_1ADTYP type C length 2,
     TEXT30 type C length 30,
  end of TS_VL_CT_J_1ADTYP .
  types:
TT_VL_CT_J_1ADTYP type standard table of TS_VL_CT_J_1ADTYP .
  types:
  begin of TS_VL_CT_J_1AGICD,
     LAND1 type C length 3,
     J_1AGICD type C length 2,
     TEXT type C length 30,
  end of TS_VL_CT_J_1AGICD .
  types:
TT_VL_CT_J_1AGICD type standard table of TS_VL_CT_J_1AGICD .
  types:
  begin of TS_VL_CT_T005,
     LAND1 type C length 3,
     LANDX type C length 15,
  end of TS_VL_CT_T005 .
  types:
TT_VL_CT_T005 type standard table of TS_VL_CT_T005 .
  types:
  begin of TS_VL_CT_T005S,
     LAND1 type C length 3,
     BLAND type C length 3,
     BEZEI type C length 20,
  end of TS_VL_CT_T005S .
  types:
TT_VL_CT_T005S type standard table of TS_VL_CT_T005S .
  types:
  begin of TS_VL_CT_T008,
     ZAHLS type C length 1,
     TEXTL type C length 20,
  end of TS_VL_CT_T008 .
  types:
TT_VL_CT_T008 type standard table of TS_VL_CT_T008 .
  types:
  begin of TS_VL_CT_T009,
     PERIV type C length 2,
     LTEXT type C length 30,
  end of TS_VL_CT_T009 .
  types:
TT_VL_CT_T009 type standard table of TS_VL_CT_T009 .
  types:
  begin of TS_VL_CT_T028V,
     VGTYP type C length 8,
     VGTXT type C length 40,
  end of TS_VL_CT_T028V .
  types:
TT_VL_CT_T028V type standard table of TS_VL_CT_T028V .
  types:
  begin of TS_VL_CT_T042F,
     UZAWE type C length 2,
     TXT30 type C length 30,
  end of TS_VL_CT_T042F .
  types:
TT_VL_CT_T042F type standard table of TS_VL_CT_T042F .
  types:
  begin of TS_VL_CT_T053R,
     BUKRS type C length 4,
     RSTGR type C length 3,
     TXT20 type C length 20,
  end of TS_VL_CT_T053R .
  types:
TT_VL_CT_T053R type standard table of TS_VL_CT_T053R .
  types:
  begin of TS_VL_CT_T054,
     DBAKZ type C length 4,
     TEXT1 type C length 50,
  end of TS_VL_CT_T054 .
  types:
TT_VL_CT_T054 type standard table of TS_VL_CT_T054 .
  types:
  begin of TS_VL_CT_T059P,
     LAND1 type C length 3,
     WITHT type C length 2,
     TEXT40 type C length 40,
  end of TS_VL_CT_T059P .
  types:
TT_VL_CT_T059P type standard table of TS_VL_CT_T059P .
  types:
  begin of TS_VL_CT_T2247,
     KMSTGE type C length 2,
     BEZEK type C length 20,
  end of TS_VL_CT_T2247 .
  types:
TT_VL_CT_T2247 type standard table of TS_VL_CT_T2247 .
  types:
  begin of TS_VL_CT_T2248,
     KMCATG type C length 2,
     BEZEK type C length 20,
  end of TS_VL_CT_T2248 .
  types:
TT_VL_CT_T2248 type standard table of TS_VL_CT_T2248 .
  types:
  begin of TS_VL_CT_T2513,
     EFORM type C length 5,
     BEZEK type C length 20,
  end of TS_VL_CT_T2513 .
  types:
TT_VL_CT_T2513 type standard table of TS_VL_CT_T2513 .
  types:
  begin of TS_VL_CT_T2538,
     GEBIE type C length 4,
     BEZEK type C length 20,
  end of TS_VL_CT_T2538 .
  types:
TT_VL_CT_T2538 type standard table of TS_VL_CT_T2538 .
  types:
  begin of TS_VL_CT_T683,
     KVEWE type C length 1,
     KAPPL type C length 2,
     KALSM type C length 6,
     VTEXT type C length 30,
  end of TS_VL_CT_T683 .
  types:
TT_VL_CT_T683 type standard table of TS_VL_CT_T683 .
  types:
  begin of TS_VL_CT_TB004,
     BPKIND type C length 4,
     TEXT40 type C length 40,
  end of TS_VL_CT_TB004 .
  types:
TT_VL_CT_TB004 type standard table of TS_VL_CT_TB004 .
  types:
  begin of TS_VL_CT_TBDLS,
     LOGSYS type C length 10,
     STEXT type C length 40,
  end of TS_VL_CT_TBDLS .
  types:
TT_VL_CT_TBDLS type standard table of TS_VL_CT_TBDLS .
  types:
  begin of TS_VL_CT_TCURC,
     WAERS type C length 5,
     LTEXT type C length 40,
  end of TS_VL_CT_TCURC .
  types:
TT_VL_CT_TCURC type standard table of TS_VL_CT_TCURC .
  types:
  begin of TS_VL_CT_TCURV,
     KURST type C length 4,
     CURVW type C length 40,
  end of TS_VL_CT_TCURV .
  types:
TT_VL_CT_TCURV type standard table of TS_VL_CT_TCURV .
  types:
  begin of TS_VL_CT_TFKB,
     FKBER type C length 16,
     FKBTX type C length 25,
  end of TS_VL_CT_TFKB .
  types:
TT_VL_CT_TFKB type standard table of TS_VL_CT_TFKB .
  types:
  begin of TS_VL_CT_TMABC,
     MAABC type C length 1,
     TMABC type C length 30,
  end of TS_VL_CT_TMABC .
  types:
TT_VL_CT_TMABC type standard table of TS_VL_CT_TMABC .
  types:
  begin of TS_VL_CT_TSTC,
     TCODE type C length 20,
     TTEXT type C length 36,
  end of TS_VL_CT_TSTC .
  types:
TT_VL_CT_TSTC type standard table of TS_VL_CT_TSTC .
  types:
  begin of TS_VL_CT_TTYP,
     AWTYP type C length 5,
     OTEXT type C length 20,
  end of TS_VL_CT_TTYP .
  types:
TT_VL_CT_TTYP type standard table of TS_VL_CT_TTYP .
  types:
  begin of TS_VL_FV_ANWND_EBKO,
     DOMVALUE_L type C length 4,
     DDTEXT type C length 60,
  end of TS_VL_FV_ANWND_EBKO .
  types:
TT_VL_FV_ANWND_EBKO type standard table of TS_VL_FV_ANWND_EBKO .
  types:
  begin of TS_VL_FV_AS4FLAG,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_AS4FLAG .
  types:
TT_VL_FV_AS4FLAG type standard table of TS_VL_FV_AS4FLAG .
  types:
  begin of TS_VL_FV_BDM_PROMISE_STATE,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_BDM_PROMISE_STATE .
  types:
TT_VL_FV_BDM_PROMISE_STATE type standard table of TS_VL_FV_BDM_PROMISE_STATE .
  types:
  begin of TS_VL_FV_BOOLE,
     DOMVALUE_L type C length 5,
     DDTEXT type C length 60,
  end of TS_VL_FV_BOOLE .
  types:
TT_VL_FV_BOOLE type standard table of TS_VL_FV_BOOLE .
  types:
  begin of TS_VL_FV_BOOLEAN,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_BOOLEAN .
  types:
TT_VL_FV_BOOLEAN type standard table of TS_VL_FV_BOOLEAN .
  types:
  begin of TS_VL_FV_BSTAT,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_BSTAT .
  types:
TT_VL_FV_BSTAT type standard table of TS_VL_FV_BSTAT .
  types:
  begin of TS_VL_FV_CHECKBOX,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_CHECKBOX .
  types:
TT_VL_FV_CHECKBOX type standard table of TS_VL_FV_CHECKBOX .
  types:
  begin of TS_VL_FV_CMIS_FS_SVR_TYPE,
     DOMVALUE_L type C length 4,
     DDTEXT type C length 60,
  end of TS_VL_FV_CMIS_FS_SVR_TYPE .
  types:
TT_VL_FV_CMIS_FS_SVR_TYPE type standard table of TS_VL_FV_CMIS_FS_SVR_TYPE .
  types:
  begin of TS_VL_FV_CMIS_FS_TYPE,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_CMIS_FS_TYPE .
  types:
TT_VL_FV_CMIS_FS_TYPE type standard table of TS_VL_FV_CMIS_FS_TYPE .
  types:
  begin of TS_VL_FV_CURRTYP,
     DOMVALUE_L type C length 2,
     DDTEXT type C length 60,
  end of TS_VL_FV_CURRTYP .
  types:
TT_VL_FV_CURRTYP type standard table of TS_VL_FV_CURRTYP .
  types:
  begin of TS_VL_FV_CURTP,
     DOMVALUE_L type C length 2,
     DDTEXT type C length 60,
  end of TS_VL_FV_CURTP .
  types:
TT_VL_FV_CURTP type standard table of TS_VL_FV_CURTP .
  types:
  begin of TS_VL_FV_CVP_XBLCK,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_CVP_XBLCK .
  types:
TT_VL_FV_CVP_XBLCK type standard table of TS_VL_FV_CVP_XBLCK .
  types:
  begin of TS_VL_FV_FAC_RJET_END_BY_TYPE,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FAC_RJET_END_BY_TYPE .
  types:
TT_VL_FV_FAC_RJET_END_BY_TYPE type standard table of TS_VL_FV_FAC_RJET_END_BY_TYPE .
  types:
  begin of TS_VL_FV_FAC_RJET_OCCUR_DAY_TY,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FAC_RJET_OCCUR_DAY_TY .
  types:
TT_VL_FV_FAC_RJET_OCCUR_DAY_TY type standard table of TS_VL_FV_FAC_RJET_OCCUR_DAY_TY .
  types:
  begin of TS_VL_FV_FAC_RJET_POSTING_STAT,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FAC_RJET_POSTING_STAT .
  types:
TT_VL_FV_FAC_RJET_POSTING_STAT type standard table of TS_VL_FV_FAC_RJET_POSTING_STAT .
  types:
  begin of TS_VL_FV_FAC_RJET_RECURRENCE_T,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FAC_RJET_RECURRENCE_T .
  types:
TT_VL_FV_FAC_RJET_RECURRENCE_T type standard table of TS_VL_FV_FAC_RJET_RECURRENCE_T .
  types:
  begin of TS_VL_FV_FAC_RJET_TRANS_LC_AMT,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FAC_RJET_TRANS_LC_AMT .
  types:
TT_VL_FV_FAC_RJET_TRANS_LC_AMT type standard table of TS_VL_FV_FAC_RJET_TRANS_LC_AMT .
  types:
  begin of TS_VL_FV_FAC_RJET_WEEK_DAY,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FAC_RJET_WEEK_DAY .
  types:
TT_VL_FV_FAC_RJET_WEEK_DAY type standard table of TS_VL_FV_FAC_RJET_WEEK_DAY .
  types:
  begin of TS_VL_FV_FARP_ASTAT_EB_SL,
     DOMVALUE_L type C length 22,
     DDTEXT type C length 60,
  end of TS_VL_FV_FARP_ASTAT_EB_SL .
  types:
TT_VL_FV_FARP_ASTAT_EB_SL type standard table of TS_VL_FV_FARP_ASTAT_EB_SL .
  types:
  begin of TS_VL_FV_FARP_BOOLEAN,
     DOMVALUE_L type C length 5,
     DDTEXT type C length 60,
  end of TS_VL_FV_FARP_BOOLEAN .
  types:
TT_VL_FV_FARP_BOOLEAN type standard table of TS_VL_FV_FARP_BOOLEAN .
  types:
  begin of TS_VL_FV_FARP_BS_ITM_LIFECYC_S,
     DOMVALUE_L type C length 20,
     DDTEXT type C length 60,
  end of TS_VL_FV_FARP_BS_ITM_LIFECYC_S .
  types:
TT_VL_FV_FARP_BS_ITM_LIFECYC_S type standard table of TS_VL_FV_FARP_BS_ITM_LIFECYC_S .
  types:
  begin of TS_VL_FV_FARP_CL_LINE_ITEM_TYP,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FARP_CL_LINE_ITEM_TYP .
  types:
TT_VL_FV_FARP_CL_LINE_ITEM_TYP type standard table of TS_VL_FV_FARP_CL_LINE_ITEM_TYP .
  types:
  begin of TS_VL_FV_FARP_KOART,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FARP_KOART .
  types:
TT_VL_FV_FARP_KOART type standard table of TS_VL_FV_FARP_KOART .
  types:
  begin of TS_VL_FV_FARP_LB_ITM_LIFECYC_S,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FARP_LB_ITM_LIFECYC_S .
  types:
TT_VL_FV_FARP_LB_ITM_LIFECYC_S type standard table of TS_VL_FV_FARP_LB_ITM_LIFECYC_S .
  types:
  begin of TS_VL_FV_FARP_MAHNS,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FARP_MAHNS .
  types:
TT_VL_FV_FARP_MAHNS type standard table of TS_VL_FV_FARP_MAHNS .
  types:
  begin of TS_VL_FV_FAR_PSTRL_APPLICATION,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FAR_PSTRL_APPLICATION .
  types:
TT_VL_FV_FAR_PSTRL_APPLICATION type standard table of TS_VL_FV_FAR_PSTRL_APPLICATION .
  types:
  begin of TS_VL_FV_FCLM_BAM_CONTRACT_TYP,
     DOMVALUE_L type C length 2,
     DDTEXT type C length 60,
  end of TS_VL_FV_FCLM_BAM_CONTRACT_TYP .
  types:
TT_VL_FV_FCLM_BAM_CONTRACT_TYP type standard table of TS_VL_FV_FCLM_BAM_CONTRACT_TYP .
  types:
  begin of TS_VL_FV_FDC_ACCDOC_HDR_ACTION,
     DOMVALUE_L type C length 15,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_ACCDOC_HDR_ACTION .
  types:
TT_VL_FV_FDC_ACCDOC_HDR_ACTION type standard table of TS_VL_FV_FDC_ACCDOC_HDR_ACTION .
  types:
  begin of TS_VL_FV_FDC_ACCDOC_ITM_ACTION,
     DOMVALUE_L type C length 4,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_ACCDOC_ITM_ACTION .
  types:
TT_VL_FV_FDC_ACCDOC_ITM_ACTION type standard table of TS_VL_FV_FDC_ACCDOC_ITM_ACTION .
  types:
  begin of TS_VL_FV_FDC_ACCDOC_ITM_COPA_V,
     DOMVALUE_L type C length 15,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_ACCDOC_ITM_COPA_V .
  types:
TT_VL_FV_FDC_ACCDOC_ITM_COPA_V type standard table of TS_VL_FV_FDC_ACCDOC_ITM_COPA_V .
  types:
  begin of TS_VL_FV_FDC_ACCDOC_TMP_DOC_TY,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_ACCDOC_TMP_DOC_TY .
  types:
TT_VL_FV_FDC_ACCDOC_TMP_DOC_TY type standard table of TS_VL_FV_FDC_ACCDOC_TMP_DOC_TY .
  types:
  begin of TS_VL_FV_FDC_APPLICATION_ID,
     DOMVALUE_L type C length 4,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_APPLICATION_ID .
  types:
TT_VL_FV_FDC_APPLICATION_ID type standard table of TS_VL_FV_FDC_APPLICATION_ID .
  types:
  begin of TS_VL_FV_FDC_APPROVAL_STATUS,
     DOMVALUE_L type C length 2,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_APPROVAL_STATUS .
  types:
TT_VL_FV_FDC_APPROVAL_STATUS type standard table of TS_VL_FV_FDC_APPROVAL_STATUS .
  types:
  begin of TS_VL_FV_FDC_DATA_ENTRY_STATUS,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_DATA_ENTRY_STATUS .
  types:
TT_VL_FV_FDC_DATA_ENTRY_STATUS type standard table of TS_VL_FV_FDC_DATA_ENTRY_STATUS .
  types:
  begin of TS_VL_FV_FDC_XCPDD_MODE,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FDC_XCPDD_MODE .
  types:
TT_VL_FV_FDC_XCPDD_MODE type standard table of TS_VL_FV_FDC_XCPDD_MODE .
  types:
  begin of TS_VL_FV_FEB_ADV_ASSIGNMENT_RE,
     DOMVALUE_L type C length 2,
     DDTEXT type C length 60,
  end of TS_VL_FV_FEB_ADV_ASSIGNMENT_RE .
  types:
TT_VL_FV_FEB_ADV_ASSIGNMENT_RE type standard table of TS_VL_FV_FEB_ADV_ASSIGNMENT_RE .
  types:
  begin of TS_VL_FV_FEB_ML_STATUS,
     DOMVALUE_L type C length 10,
     DDTEXT type C length 60,
  end of TS_VL_FV_FEB_ML_STATUS .
  types:
TT_VL_FV_FEB_ML_STATUS type standard table of TS_VL_FV_FEB_ML_STATUS .
  types:
  begin of TS_VL_FV_FEB_ML_STATUS_AD,
     DOMVALUE_L type C length 10,
     DDTEXT type C length 60,
  end of TS_VL_FV_FEB_ML_STATUS_AD .
  types:
TT_VL_FV_FEB_ML_STATUS_AD type standard table of TS_VL_FV_FEB_ML_STATUS_AD .
  types:
  begin of TS_VL_FV_FEB_N2PCHGIND,
     DOMVALUE_L type C length 10,
     DDTEXT type C length 60,
  end of TS_VL_FV_FEB_N2PCHGIND .
  types:
TT_VL_FV_FEB_N2PCHGIND type standard table of TS_VL_FV_FEB_N2PCHGIND .
  types:
  begin of TS_VL_FV_FEB_PART_APPL_STATUS,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FEB_PART_APPL_STATUS .
  types:
TT_VL_FV_FEB_PART_APPL_STATUS type standard table of TS_VL_FV_FEB_PART_APPL_STATUS .
  types:
  begin of TS_VL_FV_FIS_TMPL_ACC_POLICY,
     DOMVALUE_L type C length 2,
     DDTEXT type C length 60,
  end of TS_VL_FV_FIS_TMPL_ACC_POLICY .
  types:
TT_VL_FV_FIS_TMPL_ACC_POLICY type standard table of TS_VL_FV_FIS_TMPL_ACC_POLICY .
  types:
  begin of TS_VL_FV_FLAG,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_FLAG .
  types:
TT_VL_FV_FLAG type standard table of TS_VL_FV_FLAG .
  types:
  begin of TS_VL_FV_GLACCOUNT_TYPE,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_GLACCOUNT_TYPE .
  types:
TT_VL_FV_GLACCOUNT_TYPE type standard table of TS_VL_FV_GLACCOUNT_TYPE .
  types:
  begin of TS_VL_FV_HWMET,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_HWMET .
  types:
TT_VL_FV_HWMET type standard table of TS_VL_FV_HWMET .
  types:
  begin of TS_VL_FV_INTAG_EB,
     DOMVALUE_L type C length 10,
     DDTEXT type C length 60,
  end of TS_VL_FV_INTAG_EB .
  types:
TT_VL_FV_INTAG_EB type standard table of TS_VL_FV_INTAG_EB .
  types:
  begin of TS_VL_FV_INTTYPE,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_INTTYPE .
  types:
TT_VL_FV_INTTYPE type standard table of TS_VL_FV_INTTYPE .
  types:
  begin of TS_VL_FV_KOART,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_KOART .
  types:
TT_VL_FV_KOART type standard table of TS_VL_FV_KOART .
  types:
  begin of TS_VL_FV_KOART_AV,
     DOMVALUE_L type C length 10,
     DDTEXT type C length 60,
  end of TS_VL_FV_KOART_AV .
  types:
TT_VL_FV_KOART_AV type standard table of TS_VL_FV_KOART_AV .
  types:
  begin of TS_VL_FV_MITKZ,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_MITKZ .
  types:
TT_VL_FV_MITKZ type standard table of TS_VL_FV_MITKZ .
  types:
  begin of TS_VL_FV_MWART,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_MWART .
  types:
TT_VL_FV_MWART type standard table of TS_VL_FV_MWART .
  types:
  begin of TS_VL_FV_PFORM,
     DOMVALUE_L type C length 10,
     DDTEXT type C length 60,
  end of TS_VL_FV_PFORM .
  types:
TT_VL_FV_PFORM type standard table of TS_VL_FV_PFORM .
  types:
  begin of TS_VL_FV_RANTYP,
     DOMVALUE_L type C length 25,
     DDTEXT type C length 60,
  end of TS_VL_FV_RANTYP .
  types:
TT_VL_FV_RANTYP type standard table of TS_VL_FV_RANTYP .
  types:
  begin of TS_VL_FV_SHKZG,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_SHKZG .
  types:
TT_VL_FV_SHKZG type standard table of TS_VL_FV_SHKZG .
  types:
  begin of TS_VL_FV_WT_STAT,
     DOMVALUE_L type C length 1,
     DDTEXT type C length 60,
  end of TS_VL_FV_WT_STAT .
  types:
TT_VL_FV_WT_STAT type standard table of TS_VL_FV_WT_STAT .
  types:
  begin of TS_VL_SH_BP_BUPAG,
     PARTNER type C length 10,
  end of TS_VL_SH_BP_BUPAG .
  types:
TT_VL_SH_BP_BUPAG type standard table of TS_VL_SH_BP_BUPAG .
  types:
  begin of TS_VL_SH_BP_ERP_TREX_ADVANCED,
     ALTERNATIVE_ID_TYPE type C length 32,
     ALTERNATIVE_ID_VALUE type C length 64,
     BIRTHNAME type C length 40,
     BUSINESS_OBJECT type C length 10,
     COUNTRYKEY type C length 3,
     HOUSE_NO type C length 10,
     NAME type C length 80,
     OBJECT_TYPE type C length 10,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
     EXTERNAL_KEY type C length 10,
     CITY type C length 40,
     POSTL_COD1 type C length 10,
     STREET type C length 60,
     COUNTRY type C length 50,
     NAME1 type C length 40,
     NAME2 type C length 40,
     PARTNERROLE type C length 6,
     BIRTHDATE type TIMESTAMP,
     CENTRALBLOCK type FLAG,
     CENTRALARCHIVINGFLAG type FLAG,
  end of TS_VL_SH_BP_ERP_TREX_ADVANCED .
  types:
TT_VL_SH_BP_ERP_TREX_ADVANCED type standard table of TS_VL_SH_BP_ERP_TREX_ADVANCED .
  types:
  begin of TS_VL_SH_BP_ERP_TREX_SIMPLE,
     BIRTHDATE type TIMESTAMP,
     BUSINESS_OBJECT type C length 10,
     CITY type C length 40,
     EXTERNAL_KEY type C length 10,
     HOUSE_NO type C length 10,
     NAME type C length 80,
     OBJECT_TYPE type C length 10,
     PARTNERROLE type C length 6,
     POSTL_COD1 type C length 10,
     STREET type C length 60,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_BP_ERP_TREX_SIMPLE .
  types:
TT_VL_SH_BP_ERP_TREX_SIMPLE type standard table of TS_VL_SH_BP_ERP_TREX_SIMPLE .
  types:
  begin of TS_VL_SH_BUHI_TREE_SEARCH_TERM,
     PARTNER type C length 10,
     SEARCH_TERM type C length 20,
     DESCRIPTION type C length 40,
     LANGUAGE type C length 2,
     DESCRIPTION2 type C length 40,
  end of TS_VL_SH_BUHI_TREE_SEARCH_TERM .
  types:
TT_VL_SH_BUHI_TREE_SEARCH_TERM type standard table of TS_VL_SH_BUHI_TREE_SEARCH_TERM .
  types:
  begin of TS_VL_SH_BUPAA,
     MC_CITY1 type C length 25,
     POST_CODE1 type C length 10,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     MC_COUNTY type C length 25,
     MC_TOWNSHIP type C length 25,
     COUNTRY type C length 3,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
     VALDT type TIMESTAMP,
  end of TS_VL_SH_BUPAA .
  types:
TT_VL_SH_BUPAA type standard table of TS_VL_SH_BUPAA .
  types:
  begin of TS_VL_SH_BUPAA_VERS,
     MC_CITY1 type C length 25,
     POST_CODE1 type C length 10,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     MC_COUNTY type C length 25,
     MC_TOWNSHIP type C length 25,
     COUNTRY type C length 3,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 25,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
     NATION type C length 1,
     VALDT type TIMESTAMP,
  end of TS_VL_SH_BUPAA_VERS .
  types:
TT_VL_SH_BUPAA_VERS type standard table of TS_VL_SH_BUPAA_VERS .
  types:
  begin of TS_VL_SH_BUPAB,
     BANKL type C length 15,
     BANKN type C length 18,
     BANK_ALIAS type C length 255,
     IBAN type C length 34,
     BANKS type C length 3,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
     VALDT1 type TIMESTAMP,
  end of TS_VL_SH_BUPAB .
  types:
TT_VL_SH_BUPAB type standard table of TS_VL_SH_BUPAB .
  types:
  begin of TS_VL_SH_BUPAGUID,
     BU_SORT1 type C length 20,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     PARTNER type C length 10,
     PARTNER_GUID type X length 32,
  end of TS_VL_SH_BUPAGUID .
  types:
TT_VL_SH_BUPAGUID type standard table of TS_VL_SH_BUPAGUID .
  types:
  begin of TS_VL_SH_BUPAI,
     TEXT type C length 40,
     TYPE type C length 6,
     IDNUMBER type C length 60,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
  end of TS_VL_SH_BUPAI .
  types:
TT_VL_SH_BUPAI type standard table of TS_VL_SH_BUPAI .
  types:
  begin of TS_VL_SH_BUPAP,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
     TYPE type C length 1,
     VALDT type TIMESTAMP,
  end of TS_VL_SH_BUPAP .
  types:
TT_VL_SH_BUPAP type standard table of TS_VL_SH_BUPAP .
  types:
  begin of TS_VL_SH_BUPAR,
     RLTITL type C length 25,
     RLTYP type C length 6,
     VALDT type TIMESTAMP,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
  end of TS_VL_SH_BUPAR .
  types:
TT_VL_SH_BUPAR type standard table of TS_VL_SH_BUPAR .
  types:
  begin of TS_VL_SH_BUPARLTYP,
     RLTY_C type C length 50,
     PARTNER type C length 10,
     BP1_NAME1 type C length 35,
     BP1_NAME2 type C length 35,
     RELTYP type C length 6,
     PARTNER2 type C length 10,
     BP2_NAME1 type C length 35,
     BP2_NAME2 type C length 35,
  end of TS_VL_SH_BUPARLTYP .
  types:
TT_VL_SH_BUPARLTYP type standard table of TS_VL_SH_BUPARLTYP .
  types:
  begin of TS_VL_SH_BUPAT,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     PARTNER type C length 10,
     TAXTYPE type C length 4,
     TAXNUM type C length 20,
     TAXNUMXL type C length 60,
  end of TS_VL_SH_BUPAT .
  types:
TT_VL_SH_BUPAT type standard table of TS_VL_SH_BUPAT .
  types:
  begin of TS_VL_SH_BUPAU,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     PARTNER type C length 10,
     USER type C length 12,
  end of TS_VL_SH_BUPAU .
  types:
TT_VL_SH_BUPAU type standard table of TS_VL_SH_BUPAU .
  types:
  begin of TS_VL_SH_BUPAV,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     PARTNER type C length 10,
     INTERNETUSER type C length 40,
  end of TS_VL_SH_BUPAV .
  types:
TT_VL_SH_BUPAV type standard table of TS_VL_SH_BUPAV .
  types:
  begin of TS_VL_SH_BUPA_KUNNR,
     AUGRP type C length 4,
     PARTNER type C length 10,
     CUSTOMER type C length 10,
  end of TS_VL_SH_BUPA_KUNNR .
  types:
TT_VL_SH_BUPA_KUNNR type standard table of TS_VL_SH_BUPA_KUNNR .
  types:
  begin of TS_VL_SH_BUPA_LIFNR,
     AUGRP type C length 4,
     PARTNER type C length 10,
     SUPPLIER type C length 10,
  end of TS_VL_SH_BUPA_LIFNR .
  types:
TT_VL_SH_BUPA_LIFNR type standard table of TS_VL_SH_BUPA_LIFNR .
  types:
  begin of TS_VL_SH_BU_ADR,
     PARTNER type C length 10,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     BIRTHDT type TIMESTAMP,
     AUGRP type C length 4,
     XDELE type FLAG,
     XBLCK type FLAG,
     TYPE type C length 1,
     MC_CITY1 type C length 25,
     POST_CODE1 type C length 10,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     MC_COUNTY type C length 25,
     MC_TOWNSHIP type C length 25,
     COUNTRY type C length 3,
     REGION type C length 3,
     VALDT type TIMESTAMP,
  end of TS_VL_SH_BU_ADR .
  types:
TT_VL_SH_BU_ADR type standard table of TS_VL_SH_BU_ADR .
  types:
  begin of TS_VL_SH_CMD_PROD_BY_PRODHIER_,
     PRODHIERARCHYVALIDITYENDDATE type TIMESTAMP,
     PRODHIERARCHYVALIDITYSTARTDATE type TIMESTAMP,
     PRODUCT type C length 40,
     PRODUCTDESCRIPTION type C length 40,
     PRODUNIVHIERARCHY type C length 20,
     PRODUCTHIERARCHYPARENTNODE type C length 24,
     SALESPRODUCTHIERARCHYPURPOSE type C length 2,
     SALESORGANIZATION type C length 4,
     DISTRIBUTIONCHANNEL type C length 2,
     HIERARCHY_ASSGNMT_VALIDITY type TIMESTAMP,
     BASEUNITSPECIFICPRODUCTLENGTH type P length 7 decimals 3,
     BASEUNITSPECIFICPRODUCTWIDTH type P length 7 decimals 3,
     BASEUNITSPECIFICPRODUCTHEIGHT type P length 7 decimals 3,
     PRODUCTMEASUREMENTUNIT type C length 3,
     NETWEIGHT type P length 7 decimals 3,
     GROSSWEIGHT type P length 7 decimals 3,
     WEIGHTUNIT type C length 3,
     MATERIALVOLUME type P length 7 decimals 3,
     VOLUMEUNIT type C length 3,
     SPRAS type C length 2,
  end of TS_VL_SH_CMD_PROD_BY_PRODHIER_ .
  types:
TT_VL_SH_CMD_PROD_BY_PRODHIER_ type standard table of TS_VL_SH_CMD_PROD_BY_PRODHIER_ .
  types:
  begin of TS_VL_SH_CRM_BUPA_CONTACT_NUMB,
     NAME_FIRST type C length 40,
     NAME_LAST type C length 40,
     PARTNER type C length 10,
     CONTACT_NO type C length 10,
  end of TS_VL_SH_CRM_BUPA_CONTACT_NUMB .
  types:
TT_VL_SH_CRM_BUPA_CONTACT_NUMB type standard table of TS_VL_SH_CRM_BUPA_CONTACT_NUMB .
  types:
  begin of TS_VL_SH_CRM_BUPA_CUSTOMER_NUM,
     NAME_ORG1 type C length 40,
     NAME_ORG2 type C length 40,
     PARTNER type C length 10,
     CUSTOMER_NO type C length 10,
  end of TS_VL_SH_CRM_BUPA_CUSTOMER_NUM .
  types:
TT_VL_SH_CRM_BUPA_CUSTOMER_NUM type standard table of TS_VL_SH_CRM_BUPA_CUSTOMER_NUM .
  types:
  begin of TS_VL_SH_DD_DTEL,
     TEXT type C length 60,
     DATATYPE_ICON type C length 10,
     DOMNAME type C length 30,
     DECIMALS type C length 6,
     VARIANT type C length 14,
     REFKIND type C length 1,
     ROLLNAME type C length 30,
     DDTEXT type C length 60,
     DATATYPE type C length 10,
     LENG type C length 6,
  end of TS_VL_SH_DD_DTEL .
  types:
TT_VL_SH_DD_DTEL type standard table of TS_VL_SH_DD_DTEL .
  types:
  begin of TS_VL_SH_DD_SHLP,
     OBJTYPE type C length 15,
     TEXT type C length 60,
     ISSIMPLE type FLAG,
     HOTKEY type C length 1,
     VARIANT type C length 14,
     SHLPNAME type C length 30,
     DDTEXT type C length 60,
  end of TS_VL_SH_DD_SHLP .
  types:
TT_VL_SH_DD_SHLP type standard table of TS_VL_SH_DD_SHLP .
  types:
  begin of TS_VL_SH_DEBIA,
     BEGRU type C length 4,
     KTOKD type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     KUNNR type C length 10,
     LOEVM type FLAG,
  end of TS_VL_SH_DEBIA .
  types:
TT_VL_SH_DEBIA type standard table of TS_VL_SH_DEBIA .
  types:
  begin of TS_VL_SH_DEBID,
     BEGRU type C length 4,
     KTOKD type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     KUNNR type C length 10,
     BUKRS type C length 4,
     LOEVM type FLAG,
  end of TS_VL_SH_DEBID .
  types:
TT_VL_SH_DEBID type standard table of TS_VL_SH_DEBID .
  types:
  begin of TS_VL_SH_DEBIE,
     BEGRU type C length 4,
     LAND1 type C length 3,
     MCOD3 type C length 25,
     SORTL type C length 10,
     MCOD1 type C length 25,
     KUNNR type C length 10,
     BUKRS type C length 4,
  end of TS_VL_SH_DEBIE .
  types:
TT_VL_SH_DEBIE type standard table of TS_VL_SH_DEBIE .
  types:
  begin of TS_VL_SH_DEBIK,
     BEGRU type C length 4,
     KTOKD type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     KUNNR type C length 10,
  end of TS_VL_SH_DEBIK .
  types:
TT_VL_SH_DEBIK type standard table of TS_VL_SH_DEBIK .
  types:
  begin of TS_VL_SH_DEBIL,
     BEGRU type C length 4,
     KTOKD type C length 4,
     LAND1 type C length 3,
     SORTL type C length 10,
     MCOD1 type C length 25,
     MCOD3 type C length 25,
     KUNNR type C length 10,
  end of TS_VL_SH_DEBIL .
  types:
TT_VL_SH_DEBIL type standard table of TS_VL_SH_DEBIL .
  types:
  begin of TS_VL_SH_DEBIP,
     BEGRU type C length 4,
     KTOKD type C length 4,
     KUNNR type C length 10,
     PERNR type C length 8,
     MCOD1 type C length 25,
     BUKRS type C length 4,
  end of TS_VL_SH_DEBIP .
  types:
TT_VL_SH_DEBIP type standard table of TS_VL_SH_DEBIP .
  types:
  begin of TS_VL_SH_DEBIQ,
     BEGRU type C length 4,
     KTOKD type C length 4,
     J_3GREFTYP type C length 2,
     SORTL type C length 10,
     NAME1 type C length 35,
     KUNNR type C length 10,
  end of TS_VL_SH_DEBIQ .
  types:
TT_VL_SH_DEBIQ type standard table of TS_VL_SH_DEBIQ .
  types:
  begin of TS_VL_SH_DEBIR,
     BEGRU type C length 4,
     KTOKD type C length 4,
     J_3GETYP type C length 2,
     SORTL type C length 10,
     NAME1 type C length 35,
     KUNNR type C length 10,
  end of TS_VL_SH_DEBIR .
  types:
TT_VL_SH_DEBIR type standard table of TS_VL_SH_DEBIR .
  types:
  begin of TS_VL_SH_DEBIS,
     BEGRU type C length 4,
     KTOKD type C length 4,
     VKORG type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     KUNNR type C length 10,
     VTWEG type C length 2,
     SPART type C length 2,
     VKBUR type C length 4,
     VKGRP type C length 3,
  end of TS_VL_SH_DEBIS .
  types:
TT_VL_SH_DEBIS type standard table of TS_VL_SH_DEBIS .
  types:
  begin of TS_VL_SH_DEBIT,
     BEGRU type C length 4,
     KTOKD type C length 4,
     STCD1 type C length 16,
     STCD2 type C length 11,
     STCD3 type C length 18,
     STCD4 type C length 18,
     STCD5 type C length 60,
     STCD6 type C length 20,
     STCEG type C length 20,
     LAND1 type C length 3,
     MCOD1 type C length 25,
     KUNNR type C length 10,
  end of TS_VL_SH_DEBIT .
  types:
TT_VL_SH_DEBIT type standard table of TS_VL_SH_DEBIT .
  types:
  begin of TS_VL_SH_DEBIW,
     BEGRU type C length 4,
     KTOKD type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     WERKS type C length 4,
     KUNNR type C length 10,
  end of TS_VL_SH_DEBIW .
  types:
TT_VL_SH_DEBIW type standard table of TS_VL_SH_DEBIW .
  types:
  begin of TS_VL_SH_DEBIX,
     MC_CITY1 type C length 25,
     MC_FIRSTNAME type C length 25,
     MC_NAME type C length 25,
     MC_STREET type C length 25,
     PARNR type C length 10,
     POST_CODE2 type C length 10,
     PO_BOX type C length 10,
     KUNNR type C length 10,
     NAME type C length 40,
     FIRSTNAME type C length 40,
     SORT1 type C length 20,
     SORT2 type C length 20,
     STREET type C length 60,
     HOUSE_NUM1 type C length 10,
     POST_CODE1 type C length 10,
     CITY1 type C length 40,
     COUNTRY type C length 3,
     REGION type C length 3,
  end of TS_VL_SH_DEBIX .
  types:
TT_VL_SH_DEBIX type standard table of TS_VL_SH_DEBIX .
  types:
  begin of TS_VL_SH_DEBIY,
     KUNNR type C length 10,
  end of TS_VL_SH_DEBIY .
  types:
TT_VL_SH_DEBIY type standard table of TS_VL_SH_DEBIY .
  types:
  begin of TS_VL_SH_DEBIZ,
     BEGRU type C length 4,
     KTOKD type C length 4,
     KNRZE type C length 10,
     MCOD1 type C length 25,
     MCOD3 type C length 25,
     KUNNR type C length 10,
     BUKRS type C length 4,
  end of TS_VL_SH_DEBIZ .
  types:
TT_VL_SH_DEBIZ type standard table of TS_VL_SH_DEBIZ .
  types:
  begin of TS_VL_SH_DEBI_ES_ADVANCED,
     STREET type C length 60,
     REQUEST type C length 32,
     POST_CODE1 type C length 10,
     OBJECT_TYPE_ID type C length 20,
     NAME2 type C length 40,
     KUNNR_EXT type C length 10,
     HOUSE_NUM1 type C length 10,
     COUNTRY1 type C length 3,
     CITY1 type C length 40,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type FLAG,
     KUNNR1 type C length 10,
     CUSTOMER_NAME1 type C length 40,
     NAME21 type C length 40,
     CITY11 type C length 40,
     POST_CODE11 type C length 10,
     STREET1 type C length 60,
     HOUSE_NUM11 type C length 10,
     COUNTRY type C length 50,
     VKORG type C length 4,
     VTWEG type C length 2,
     SPART type C length 2,
     NAMEV type C length 35,
     DEPARTMENT type C length 40,
     FUNCTION type C length 40,
     DEL_FLAG_G type FLAG,
  end of TS_VL_SH_DEBI_ES_ADVANCED .
  types:
TT_VL_SH_DEBI_ES_ADVANCED type standard table of TS_VL_SH_DEBI_ES_ADVANCED .
  types:
  begin of TS_VL_SH_DEBI_ES_ADVANCED_CDS,
     CDS_ENTITY_CHAR_1_TO_19 type C length 30,
     COUNTRY type C length 3,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type FLAG,
     CUSTOMER type C length 10,
     ORGANIZATIONBPNAME1 type C length 40,
     ORGANIZATIONBPNAME2 type C length 40,
     CITYNAME type C length 40,
     POSTALCODE type C length 10,
     STREETNAME type C length 60,
     HOUSENUMBER type C length 10,
     SALESORGANIZATIONNAME type C length 4,
     DISTRIBUTIONCHANNELNAME type C length 2,
     DIVISIONNAME type C length 2,
     CONTACTPERSONFIRSTNAME type C length 35,
     CONTACTPERSONDEPARTMENT type C length 40,
     CONTACTPERSONFUNCTION type C length 40,
     DELETIONINDICATOR type FLAG,
  end of TS_VL_SH_DEBI_ES_ADVANCED_CDS .
  types:
TT_VL_SH_DEBI_ES_ADVANCED_CDS type standard table of TS_VL_SH_DEBI_ES_ADVANCED_CDS .
  types:
  begin of TS_VL_SH_DEBI_ES_SIMPLE,
     CITY1 type C length 40,
     COUNTRY type C length 3,
     CUSTOMER_NAME1 type C length 40,
     HOUSE_NUM1 type C length 10,
     KUNNR_EXT type C length 10,
     NAME2 type C length 40,
     OBJECT_TYPE_ID type C length 20,
     POST_CODE1 type C length 10,
     REQUEST type C length 32,
     STREET type C length 60,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type FLAG,
  end of TS_VL_SH_DEBI_ES_SIMPLE .
  types:
TT_VL_SH_DEBI_ES_SIMPLE type standard table of TS_VL_SH_DEBI_ES_SIMPLE .
  types:
  begin of TS_VL_SH_EANE_RFQ_QUOTE_H,
     LFEAN type FLAG,
     MATNR type C length 40,
     MEINH type C length 3,
     LIFNR type C length 10,
     EAN11 type C length 18,
     MAKTG type C length 40,
     LARTN type C length 35,
  end of TS_VL_SH_EANE_RFQ_QUOTE_H .
  types:
TT_VL_SH_EANE_RFQ_QUOTE_H type standard table of TS_VL_SH_EANE_RFQ_QUOTE_H .
  types:
  begin of TS_VL_SH_F4_BL_BANK,
     LOEVM type FLAG,
     BANKS type C length 3,
     BANKL type C length 15,
     BANKA type C length 60,
     ORT01 type C length 35,
     SWIFT type C length 11,
     BNKLZ type C length 15,
  end of TS_VL_SH_F4_BL_BANK .
  types:
TT_VL_SH_F4_BL_BANK type standard table of TS_VL_SH_F4_BL_BANK .
  types:
  begin of TS_VL_SH_FAC_ASSET,
     KEYDATE type TIMESTAMP,
     ANLN1 type C length 12,
     ANLN2 type C length 4,
     MCOA1 type C length 50,
     ANLKL type C length 8,
     BUKRS type C length 4,
     KOSTL type C length 10,
     WERKS type C length 4,
     GSBER type C length 4,
     PRCTR type C length 10,
     ADATU type TIMESTAMP,
     BDATU type TIMESTAMP,
  end of TS_VL_SH_FAC_ASSET .
  types:
TT_VL_SH_FAC_ASSET type standard table of TS_VL_SH_FAC_ASSET .
  types:
  begin of TS_VL_SH_FAC_ASSET_TRANSACTION,
     BWASL type C length 3,
     BWATXT type C length 50,
  end of TS_VL_SH_FAC_ASSET_TRANSACTION .
  types:
TT_VL_SH_FAC_ASSET_TRANSACTION type standard table of TS_VL_SH_FAC_ASSET_TRANSACTION .
  types:
  begin of TS_VL_SH_FAC_BVTYP_SHLP,
     BVTYP type C length 4,
     BUKRS type C length 4,
     LIFNR type C length 10,
     KUNNR type C length 10,
     FILKD type C length 10,
     BANKN type C length 18,
     BANKL type C length 15,
     BANKS type C length 3,
     BKONT type C length 2,
     BKREF type C length 20,
     IBAN type C length 34,
  end of TS_VL_SH_FAC_BVTYP_SHLP .
  types:
TT_VL_SH_FAC_BVTYP_SHLP type standard table of TS_VL_SH_FAC_BVTYP_SHLP .
  types:
  begin of TS_VL_SH_FAC_COST_CENTER,
     KOKRS type C length 4,
     BUKRS type C length 4,
     SPRAS type C length 2,
     KEYDATE type TIMESTAMP,
     KOSTL type C length 10,
     KTEXT type C length 20,
     KOSAR type C length 1,
     VERAK type C length 20,
     VERAK_USER type C length 12,
     LTEXT type C length 40,
     DATAB type TIMESTAMP,
     DATBI type TIMESTAMP,
  end of TS_VL_SH_FAC_COST_CENTER .
  types:
TT_VL_SH_FAC_COST_CENTER type standard table of TS_VL_SH_FAC_COST_CENTER .
  types:
  begin of TS_VL_SH_FAC_COST_OBJECT,
     KOKRS type C length 4,
     SPRAS type C length 2,
     KSTRG type C length 12,
     KTEXT type C length 40,
     KTRAT type C length 4,
  end of TS_VL_SH_FAC_COST_OBJECT .
  types:
TT_VL_SH_FAC_COST_OBJECT type standard table of TS_VL_SH_FAC_COST_OBJECT .
  types:
  begin of TS_VL_SH_FAC_CUSTOMER,
     BEGRU type C length 4,
     KUNNR type C length 10,
     BUKRS type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
  end of TS_VL_SH_FAC_CUSTOMER .
  types:
TT_VL_SH_FAC_CUSTOMER type standard table of TS_VL_SH_FAC_CUSTOMER .
  types:
  begin of TS_VL_SH_FAC_DTWS1_SHLP,
     DTWSF type C length 1,
     CODE type C length 12,
     TEXT type C length 15,
     DTWSX_T type C length 50,
     BUKRS type C length 4,
     HBKID type C length 5,
     ZLSCH type C length 1,
     DTWSX type C length 2,
  end of TS_VL_SH_FAC_DTWS1_SHLP .
  types:
TT_VL_SH_FAC_DTWS1_SHLP type standard table of TS_VL_SH_FAC_DTWS1_SHLP .
  types:
  begin of TS_VL_SH_FAC_DTWS2_SHLP,
     DTWSF type C length 1,
     CODE type C length 12,
     TEXT type C length 15,
     DTWSX_T type C length 50,
     BUKRS type C length 4,
     HBKID type C length 5,
     ZLSCH type C length 1,
     DTWSX type C length 2,
  end of TS_VL_SH_FAC_DTWS2_SHLP .
  types:
TT_VL_SH_FAC_DTWS2_SHLP type standard table of TS_VL_SH_FAC_DTWS2_SHLP .
  types:
  begin of TS_VL_SH_FAC_DTWS3_SHLP,
     DTWSF type C length 1,
     CODE type C length 12,
     TEXT type C length 15,
     DTWSX_T type C length 50,
     BUKRS type C length 4,
     HBKID type C length 5,
     ZLSCH type C length 1,
     DTWSX type C length 2,
  end of TS_VL_SH_FAC_DTWS3_SHLP .
  types:
TT_VL_SH_FAC_DTWS3_SHLP type standard table of TS_VL_SH_FAC_DTWS3_SHLP .
  types:
  begin of TS_VL_SH_FAC_DTWS4_SHLP,
     DTWSF type C length 1,
     CODE type C length 12,
     TEXT type C length 15,
     DTWSX_T type C length 50,
     BUKRS type C length 4,
     HBKID type C length 5,
     ZLSCH type C length 1,
     DTWSX type C length 2,
  end of TS_VL_SH_FAC_DTWS4_SHLP .
  types:
TT_VL_SH_FAC_DTWS4_SHLP type standard table of TS_VL_SH_FAC_DTWS4_SHLP .
  types:
  begin of TS_VL_SH_FAC_EMPFB_SHLP,
     EMPFB type C length 10,
     BUKRS type C length 4,
     LIFNR type C length 10,
     KUNNR type C length 10,
     FILKD type C length 10,
     NAME1 type C length 30,
     ORT01 type C length 25,
     STRAS type C length 30,
     PFACH type C length 10,
  end of TS_VL_SH_FAC_EMPFB_SHLP .
  types:
TT_VL_SH_FAC_EMPFB_SHLP type standard table of TS_VL_SH_FAC_EMPFB_SHLP .
  types:
  begin of TS_VL_SH_FAC_FIN_TRANSACTION_T,
     TRTYP type C length 3,
     TXT type C length 20,
  end of TS_VL_SH_FAC_FIN_TRANSACTION_T .
  types:
TT_VL_SH_FAC_FIN_TRANSACTION_T type standard table of TS_VL_SH_FAC_FIN_TRANSACTION_T .
  types:
  begin of TS_VL_SH_FAC_GL_ACCOUNT,
     SPRAS type C length 2,
     GLACCT type C length 10,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     KTOPL type C length 4,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_GL_ACCOUNT .
  types:
TT_VL_SH_FAC_GL_ACCOUNT type standard table of TS_VL_SH_FAC_GL_ACCOUNT .
  types:
  begin of TS_VL_SH_FAC_GL_ACCT,
     SPRAS type C length 2,
     GLACCT type C length 10,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     KTOPL type C length 4,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_GL_ACCT .
  types:
TT_VL_SH_FAC_GL_ACCT type standard table of TS_VL_SH_FAC_GL_ACCT .
  types:
  begin of TS_VL_SH_FAC_GL_ACCT_CASH,
     SPRAS type C length 2,
     GLACCT type C length 10,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     KTOPL type C length 4,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_GL_ACCT_CASH .
  types:
TT_VL_SH_FAC_GL_ACCT_CASH type standard table of TS_VL_SH_FAC_GL_ACCT_CASH .
  types:
  begin of TS_VL_SH_FAC_GL_ACCT_LG,
     SPRAS type C length 2,
     GLACCT type C length 10,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     KTOPL type C length 4,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_GL_ACCT_LG .
  types:
TT_VL_SH_FAC_GL_ACCT_LG type standard table of TS_VL_SH_FAC_GL_ACCT_LG .
  types:
  begin of TS_VL_SH_FAC_GL_ACCT_LG_LOCAL,
     SPRAS type C length 2,
     GLACCT type C length 10,
     HKONT type C length 10,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_GL_ACCT_LG_LOCAL .
  types:
TT_VL_SH_FAC_GL_ACCT_LG_LOCAL type standard table of TS_VL_SH_FAC_GL_ACCT_LG_LOCAL .
  types:
  begin of TS_VL_SH_FAC_GL_ACCT_LOCAL,
     SPRAS type C length 2,
     GLACCT type C length 10,
     HKONT type C length 10,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_GL_ACCT_LOCAL .
  types:
TT_VL_SH_FAC_GL_ACCT_LOCAL type standard table of TS_VL_SH_FAC_GL_ACCT_LOCAL .
  types:
  begin of TS_VL_SH_FAC_GL_ACCT_WL,
     GLACCOUNT type C length 10,
     GLACCOUNTNAME type C length 20,
     GLACCOUNTLONGNAME type C length 50,
     CHARTOFACCOUNTS type C length 4,
     COMPANYCODE type C length 4,
  end of TS_VL_SH_FAC_GL_ACCT_WL .
  types:
TT_VL_SH_FAC_GL_ACCT_WL type standard table of TS_VL_SH_FAC_GL_ACCT_WL .
  types:
  begin of TS_VL_SH_FAC_HBKID_SHLP,
     BUKRS type C length 4,
     HKONT type C length 10,
     HBKID type C length 5,
     BANKS type C length 3,
     BANKL type C length 15,
     BANKA type C length 60,
     ORT01 type C length 35,
  end of TS_VL_SH_FAC_HBKID_SHLP .
  types:
TT_VL_SH_FAC_HBKID_SHLP type standard table of TS_VL_SH_FAC_HBKID_SHLP .
  types:
  begin of TS_VL_SH_FAC_HKTID_SHLP,
     BUKRS type C length 4,
     HKONT type C length 10,
     HBKID type C length 5,
     HKTID type C length 5,
     TEXT1 type C length 50,
  end of TS_VL_SH_FAC_HKTID_SHLP .
  types:
TT_VL_SH_FAC_HKTID_SHLP type standard table of TS_VL_SH_FAC_HKTID_SHLP .
  types:
  begin of TS_VL_SH_FAC_MATERIAL,
     SPRAS type C length 2,
     BUKRS type C length 4,
     MATNR type C length 40,
     MAKTX type C length 40,
     MTART type C length 4,
     MATKL type C length 9,
     WERKS type C length 4,
  end of TS_VL_SH_FAC_MATERIAL .
  types:
TT_VL_SH_FAC_MATERIAL type standard table of TS_VL_SH_FAC_MATERIAL .
  types:
  begin of TS_VL_SH_FAC_NETWORK,
     KOKRS type C length 4,
     AUFNR type C length 12,
     KTEXT type C length 40,
     PLNNR type C length 8,
     PLNAL type C length 2,
     PRONR type C length 24,
     KDAUF type C length 10,
     KDPOS type C length 6,
  end of TS_VL_SH_FAC_NETWORK .
  types:
TT_VL_SH_FAC_NETWORK type standard table of TS_VL_SH_FAC_NETWORK .
  types:
  begin of TS_VL_SH_FAC_NETWORK_ACTIVITY,
     AUFNR type C length 12,
     VORNR type C length 4,
     LTXA1 type C length 40,
  end of TS_VL_SH_FAC_NETWORK_ACTIVITY .
  types:
TT_VL_SH_FAC_NETWORK_ACTIVITY type standard table of TS_VL_SH_FAC_NETWORK_ACTIVITY .
  types:
  begin of TS_VL_SH_FAC_ORDER,
     KOKRS type C length 4,
     AUFNR type C length 12,
     KTEXT type C length 40,
     AUART type C length 4,
  end of TS_VL_SH_FAC_ORDER .
  types:
TT_VL_SH_FAC_ORDER type standard table of TS_VL_SH_FAC_ORDER .
  types:
  begin of TS_VL_SH_FAC_ORDER_ACTIVITY,
     AUFNR type C length 12,
     VORNR type C length 4,
     LTXA1 type C length 40,
  end of TS_VL_SH_FAC_ORDER_ACTIVITY .
  types:
TT_VL_SH_FAC_ORDER_ACTIVITY type standard table of TS_VL_SH_FAC_ORDER_ACTIVITY .
  types:
  begin of TS_VL_SH_FAC_PROFIT_CENTER,
     BUKRS type C length 4,
     PRCTR type C length 10,
     KTEXT type C length 20,
     LTEXT type C length 40,
     VERAK_USER type C length 12,
     VERAK type C length 20,
     DATBI type TIMESTAMP,
     KOKRS type C length 4,
  end of TS_VL_SH_FAC_PROFIT_CENTER .
  types:
TT_VL_SH_FAC_PROFIT_CENTER type standard table of TS_VL_SH_FAC_PROFIT_CENTER .
  types:
  begin of TS_VL_SH_FAC_PS_POSID,
     POSID type C length 24,
     POST1 type C length 40,
     POSKI type C length 16,
     VERNR type C length 8,
     VERNA type C length 25,
     PBUKR type C length 4,
     PKOKR type C length 4,
     PSPID type C length 24,
  end of TS_VL_SH_FAC_PS_POSID .
  types:
TT_VL_SH_FAC_PS_POSID type standard table of TS_VL_SH_FAC_PS_POSID .
  types:
  begin of TS_VL_SH_FAC_PURCHASING_DOC,
     BSTYP type C length 1,
     BSART type C length 4,
     KOKRS type C length 4,
     BUKRS type C length 4,
     EBELN type C length 10,
     LIFNR type C length 10,
     KOSTL type C length 10,
     VBELN type C length 10,
     VBELP type C length 6,
     AUFNR type C length 12,
     KSTRG type C length 12,
     PS_PSP_PNR type C length 24,
  end of TS_VL_SH_FAC_PURCHASING_DOC .
  types:
TT_VL_SH_FAC_PURCHASING_DOC type standard table of TS_VL_SH_FAC_PURCHASING_DOC .
  types:
  begin of TS_VL_SH_FAC_PURCHASING_DOC_IT,
     EBELN type C length 10,
     EBELP type C length 5,
     TXZ01 type C length 40,
  end of TS_VL_SH_FAC_PURCHASING_DOC_IT .
  types:
TT_VL_SH_FAC_PURCHASING_DOC_IT type standard table of TS_VL_SH_FAC_PURCHASING_DOC_IT .
  types:
  begin of TS_VL_SH_FAC_RECON_ACCT,
     KTOPL type C length 4,
     HKONT type C length 10,
     SPRAS type C length 2,
     GLACCT_TXT20 type C length 20,
     GLACCT_TXT50 type C length 50,
     BUKRS type C length 4,
     KOART type C length 1,
     UMSKZ type C length 1,
     SAKNR type C length 10,
  end of TS_VL_SH_FAC_RECON_ACCT .
  types:
TT_VL_SH_FAC_RECON_ACCT type standard table of TS_VL_SH_FAC_RECON_ACCT .
  types:
  begin of TS_VL_SH_FAC_REVERSAL_REASON,
     STGRD type C length 2,
     TXT40 type C length 40,
  end of TS_VL_SH_FAC_REVERSAL_REASON .
  types:
TT_VL_SH_FAC_REVERSAL_REASON type standard table of TS_VL_SH_FAC_REVERSAL_REASON .
  types:
  begin of TS_VL_SH_FAC_SALES_ORDER,
     VBELN type C length 10,
     AUART type C length 4,
     KUNNR type C length 10,
     VKORG type C length 4,
     VTWEG type C length 2,
     KOKRS type C length 4,
  end of TS_VL_SH_FAC_SALES_ORDER .
  types:
TT_VL_SH_FAC_SALES_ORDER type standard table of TS_VL_SH_FAC_SALES_ORDER .
  types:
  begin of TS_VL_SH_FAC_SALES_ORDER_ITEM,
     SPRAS type C length 2,
     VBELN type C length 10,
     POSNR type C length 6,
     MATNR type C length 40,
     MAKTX type C length 40,
  end of TS_VL_SH_FAC_SALES_ORDER_ITEM .
  types:
TT_VL_SH_FAC_SALES_ORDER_ITEM type standard table of TS_VL_SH_FAC_SALES_ORDER_ITEM .
  types:
  begin of TS_VL_SH_FAC_SEGMENT,
     SEGMENT type C length 10,
     NAME type C length 50,
  end of TS_VL_SH_FAC_SEGMENT .
  types:
TT_VL_SH_FAC_SEGMENT type standard table of TS_VL_SH_FAC_SEGMENT .
  types:
  begin of TS_VL_SH_FAC_SH_DOWN_PAYMENTS,
     SPRAS type C length 2,
     UMSKZ type C length 1,
     KOART type C length 1,
     LTEXT type C length 30,
  end of TS_VL_SH_FAC_SH_DOWN_PAYMENTS .
  types:
TT_VL_SH_FAC_SH_DOWN_PAYMENTS type standard table of TS_VL_SH_FAC_SH_DOWN_PAYMENTS .
  types:
  begin of TS_VL_SH_FAC_SUBASSET,
     ANLN1 type C length 12,
     ANLN2 type C length 4,
     MCOA1 type C length 50,
  end of TS_VL_SH_FAC_SUBASSET .
  types:
TT_VL_SH_FAC_SUBASSET type standard table of TS_VL_SH_FAC_SUBASSET .
  types:
  begin of TS_VL_SH_FAC_TAX_JURISDICTION_,
     SPRAS type C length 2,
     TXJCD type C length 15,
     TEXT1 type C length 50,
     KALSM type C length 6,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_TAX_JURISDICTION_ .
  types:
TT_VL_SH_FAC_TAX_JURISDICTION_ type standard table of TS_VL_SH_FAC_TAX_JURISDICTION_ .
  types:
  begin of TS_VL_SH_FAC_TAX_JURISDICTION,
     TXJCD_EXT type C length 15,
     BUKRS type C length 4,
     STATE type C length 3,
     COUNTY type C length 35,
     CITY type C length 35,
     ZIPCODE type C length 10,
     STREET type C length 60,
     STREET1 type C length 40,
  end of TS_VL_SH_FAC_TAX_JURISDICTION .
  types:
TT_VL_SH_FAC_TAX_JURISDICTION type standard table of TS_VL_SH_FAC_TAX_JURISDICTION .
  types:
  begin of TS_VL_SH_FAC_UMSKZ,
     UMSKZ type C length 1,
     SPRAS type C length 2,
     KOART type C length 1,
     LTEXT type C length 30,
  end of TS_VL_SH_FAC_UMSKZ .
  types:
TT_VL_SH_FAC_UMSKZ type standard table of TS_VL_SH_FAC_UMSKZ .
  types:
  begin of TS_VL_SH_FAC_VENDOR,
     BEGRU type C length 4,
     LIFNR type C length 10,
     BUKRS type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
  end of TS_VL_SH_FAC_VENDOR .
  types:
TT_VL_SH_FAC_VENDOR type standard table of TS_VL_SH_FAC_VENDOR .
  types:
  begin of TS_VL_SH_FAC_WHTX_CODE,
     SPRAS type C length 2,
     WT_WITHCD type C length 2,
     TEXT40 type C length 40,
     WITHT type C length 2,
     BUKRS type C length 4,
  end of TS_VL_SH_FAC_WHTX_CODE .
  types:
TT_VL_SH_FAC_WHTX_CODE type standard table of TS_VL_SH_FAC_WHTX_CODE .
  types:
  begin of TS_VL_SH_FAGL_LEDGERGROUP_WITH,
     LDGRP type C length 4,
     LEDGERNAME type C length 50,
     NAME type C length 50,
  end of TS_VL_SH_FAGL_LEDGERGROUP_WITH .
  types:
TT_VL_SH_FAGL_LEDGERGROUP_WITH type standard table of TS_VL_SH_FAGL_LEDGERGROUP_WITH .
  types:
  begin of TS_VL_SH_FARP_HOUSEBANK_VH,
     BUKRS type C length 4,
     HBKID type C length 5,
     BANKS type C length 3,
     BANKL type C length 15,
     BANKA type C length 60,
     ORT01 type C length 35,
  end of TS_VL_SH_FARP_HOUSEBANK_VH .
  types:
TT_VL_SH_FARP_HOUSEBANK_VH type standard table of TS_VL_SH_FARP_HOUSEBANK_VH .
  types:
  begin of TS_VL_SH_FARP_ZLSCH_BY_BUKRS,
     LAND1 type C length 3,
     TEXT2 type C length 30,
     TEXT1 type C length 30,
     BUKRS type C length 4,
     ZLSCH type C length 1,
  end of TS_VL_SH_FARP_ZLSCH_BY_BUKRS .
  types:
TT_VL_SH_FARP_ZLSCH_BY_BUKRS type standard table of TS_VL_SH_FARP_ZLSCH_BY_BUKRS .
  types:
  begin of TS_VL_SH_FAR_PYADV_SH,
     COMPANYCODE type C length 4,
     ACCOUNTTYPE type C length 1,
     ACCOUNT type C length 10,
     PAYMENTADVICE type C length 16,
     PAYMENTADVICETYPE type C length 2,
     CURRENCY type C length 5,
     PAYMENTAMOUNT type P length 8 decimals 2,
     CREATIONDATE type TIMESTAMP,
  end of TS_VL_SH_FAR_PYADV_SH .
  types:
TT_VL_SH_FAR_PYADV_SH type standard table of TS_VL_SH_FAR_PYADV_SH .
  types:
  begin of TS_VL_SH_FCLM_BAM_SHLP_ACC_TYP,
     ACC_TYPE_ID type C length 10,
     ACC_TYPE_DESC type C length 60,
     CONTRACT_TYPE type C length 2,
  end of TS_VL_SH_FCLM_BAM_SHLP_ACC_TYP .
  types:
TT_VL_SH_FCLM_BAM_SHLP_ACC_TYP type standard table of TS_VL_SH_FCLM_BAM_SHLP_ACC_TYP .
  types:
  begin of TS_VL_SH_FCLM_BAM_SHLP_ACNTNUM,
     BANKS type C length 3,
     BANKL type C length 15,
     BANKA type C length 60,
     ACC_ID type C length 10,
     ACC_NUM type C length 40,
     ACC_TYPE_ID type C length 10,
     WAERS type C length 5,
     BUKRS type C length 4,
     IBAN type C length 34,
     DESCRIPTION type C length 60,
  end of TS_VL_SH_FCLM_BAM_SHLP_ACNTNUM .
  types:
TT_VL_SH_FCLM_BAM_SHLP_ACNTNUM type standard table of TS_VL_SH_FCLM_BAM_SHLP_ACNTNUM .
  types:
  begin of TS_VL_SH_FCO_SHLP_SOLUTION_ORD,
     SERVICEOBJECTTYPE type C length 10,
     SERVICEDOCUMENT type C length 10,
     SERVICEDOCUMENTDESCRIPTION type C length 40,
  end of TS_VL_SH_FCO_SHLP_SOLUTION_ORD .
  types:
TT_VL_SH_FCO_SHLP_SOLUTION_ORD type standard table of TS_VL_SH_FCO_SHLP_SOLUTION_ORD .
  types:
  begin of TS_VL_SH_FCO_SHLP_SRVDOC,
     GLBUSINESSTRANSACTIONTYPE type C length 4,
     SERVICEDOCUMENTTYPE type C length 4,
     SERVICEDOCUMENT type C length 10,
     SERVICEDOCUMENTDESCRIPTION type C length 40,
     SERVICEDOCITEMCATEGORY type C length 4,
     SERVICEDOCUMENTITEM type C length 6,
     SERVICEDOCUMENTITEMDESCRIPTION type C length 40,
     ORIGINALLYREQUESTEDPRODUCT type C length 54,
     POSTINGDATE type TIMESTAMP,
     PROFITCENTER type C length 10,
     COMPANYCODE type C length 4,
  end of TS_VL_SH_FCO_SHLP_SRVDOC .
  types:
TT_VL_SH_FCO_SHLP_SRVDOC type standard table of TS_VL_SH_FCO_SHLP_SRVDOC .
  types:
  begin of TS_VL_SH_FCO_SHLP_SRVDOC_ITEM,
     GLBUSINESSTRANSACTIONTYPE type C length 4,
     SERVICEDOCUMENTTYPE type C length 4,
     SERVICEDOCUMENT type C length 10,
     SERVICEDOCUMENTDESCRIPTION type C length 40,
     SERVICEDOCITEMCATEGORY type C length 4,
     SERVICEDOCUMENTITEM type C length 6,
     SERVICEDOCUMENTITEMDESCRIPTION type C length 40,
     ORIGINALLYREQUESTEDPRODUCT type C length 54,
     POSTINGDATE type TIMESTAMP,
     COMPANYCODE type C length 4,
     PROFITCENTER type C length 10,
  end of TS_VL_SH_FCO_SHLP_SRVDOC_ITEM .
  types:
TT_VL_SH_FCO_SHLP_SRVDOC_ITEM type standard table of TS_VL_SH_FCO_SHLP_SRVDOC_ITEM .
  types:
  begin of TS_VL_SH_FCO_SHLP_SRVDOC_TYPE,
     GLBUSINESSTRANSACTIONTYPE type C length 4,
     SERVICEDOCUMENTTYPENAME type C length 40,
     SERVICEDOCUMENTTYPE type C length 4,
  end of TS_VL_SH_FCO_SHLP_SRVDOC_TYPE .
  types:
TT_VL_SH_FCO_SHLP_SRVDOC_TYPE type standard table of TS_VL_SH_FCO_SHLP_SRVDOC_TYPE .
  types:
  begin of TS_VL_SH_FDMO_CASE_PRIORITY,
     PRIORITY type C length 1,
     DESCRIPTION type C length 40,
  end of TS_VL_SH_FDMO_CASE_PRIORITY .
  types:
TT_VL_SH_FDMO_CASE_PRIORITY type standard table of TS_VL_SH_FDMO_CASE_PRIORITY .
  types:
  begin of TS_VL_SH_FDMO_REASON_CODE,
     REASON_CODE type C length 4,
     DESCRIPTION type C length 60,
     BUKRS type C length 4,
  end of TS_VL_SH_FDMO_REASON_CODE .
  types:
TT_VL_SH_FDMO_REASON_CODE type standard table of TS_VL_SH_FDMO_REASON_CODE .
  types:
  begin of TS_VL_SH_FDMO_USER,
     ISTECHNICALUSER type FLAG,
     USERID type C length 12,
     USERDESCRIPTION type C length 80,
  end of TS_VL_SH_FDMO_USER .
  types:
TT_VL_SH_FDMO_USER type standard table of TS_VL_SH_FDMO_USER .
  types:
  begin of TS_VL_SH_FEB_SH_OI_ALG,
     OI_FIND_ALG type C length 30,
     DESCRIPTION type C length 255,
  end of TS_VL_SH_FEB_SH_OI_ALG .
  types:
TT_VL_SH_FEB_SH_OI_ALG type standard table of TS_VL_SH_FEB_SH_OI_ALG .
  types:
  begin of TS_VL_SH_FIKR_ELM_BELNR,
     BELNR type C length 10,
     BUKRS type C length 4,
     GJAHR type C length 4,
  end of TS_VL_SH_FIKR_ELM_BELNR .
  types:
TT_VL_SH_FIKR_ELM_BELNR type standard table of TS_VL_SH_FIKR_ELM_BELNR .
  types:
  begin of TS_VL_SH_FINS_LEDGER,
     RLDNR type C length 2,
     NAME type C length 30,
     XLEADING type FLAG,
  end of TS_VL_SH_FINS_LEDGER .
  types:
TT_VL_SH_FINS_LEDGER type standard table of TS_VL_SH_FINS_LEDGER .
  types:
  begin of TS_VL_SH_FIS_TMPL_SH_APPCODE,
     APPTEXT type C length 60,
     APPCODE type C length 20,
  end of TS_VL_SH_FIS_TMPL_SH_APPCODE .
  types:
TT_VL_SH_FIS_TMPL_SH_APPCODE type standard table of TS_VL_SH_FIS_TMPL_SH_APPCODE .
  types:
  begin of TS_VL_SH_FI_UMKRS,
     ADRNR type C length 10,
     NAME1 type C length 40,
     UMKRS type C length 4,
     TBUKRS type C length 4,
  end of TS_VL_SH_FI_UMKRS .
  types:
TT_VL_SH_FI_UMKRS type standard table of TS_VL_SH_FI_UMKRS .
  types:
  begin of TS_VL_SH_FKKVT_F4_BEZ,
     BEGRU type C length 4,
     BUKRS type C length 4,
     VTBEZ type C length 35,
     VTKEY type C length 20,
     GPART type C length 10,
     VKONT type C length 12,
     VTALT type C length 20,
     VTCAT type C length 1,
     VTCHR type C length 1,
  end of TS_VL_SH_FKKVT_F4_BEZ .
  types:
TT_VL_SH_FKKVT_F4_BEZ type standard table of TS_VL_SH_FKKVT_F4_BEZ .
  types:
  begin of TS_VL_SH_FKKVT_F4_DDL,
     BEGRU type C length 4,
     BUKRS type C length 4,
     VTCAT type C length 1,
     VTKEY type C length 20,
     GPART type C length 10,
     VTBEZ type C length 35,
  end of TS_VL_SH_FKKVT_F4_DDL .
  types:
TT_VL_SH_FKKVT_F4_DDL type standard table of TS_VL_SH_FKKVT_F4_DDL .
  types:
  begin of TS_VL_SH_FKKVT_F4_TR,
     BEGRU type C length 4,
     BUKRS type C length 4,
     GPART type C length 10,
     VTALT type C length 20,
     VTBEZ type C length 35,
     VTCAT type C length 1,
     VTCHR type C length 1,
     VTKEY type C length 20,
     VTTRN type C length 50,
     VTTRT type C length 2,
     VTTRI type C length 50,
  end of TS_VL_SH_FKKVT_F4_TR .
  types:
TT_VL_SH_FKKVT_F4_TR type standard table of TS_VL_SH_FKKVT_F4_TR .
  types:
  begin of TS_VL_SH_FKK_CM_CPERS,
     DATE_FROM type TIMESTAMP,
     DATE_TO type TIMESTAMP,
     NAME_FIRST type C length 40,
     NAME_LAST type C length 40,
     PARTNER2 type C length 10,
     PARTNER1 type C length 10,
  end of TS_VL_SH_FKK_CM_CPERS .
  types:
TT_VL_SH_FKK_CM_CPERS type standard table of TS_VL_SH_FKK_CM_CPERS .
  types:
  begin of TS_VL_SH_FKK_RECENT_GPART,
     CPUDT type TIMESTAMP,
     CPUTM type T,
     DESCRIPTION type C length 80,
     GPART type C length 10,
     DATFR type TIMESTAMP,
  end of TS_VL_SH_FKK_RECENT_GPART .
  types:
TT_VL_SH_FKK_RECENT_GPART type standard table of TS_VL_SH_FKK_RECENT_GPART .
  types:
  begin of TS_VL_SH_FKK_RECENT_VTKEY,
     VTKEY type C length 20,
     DATFR type TIMESTAMP,
  end of TS_VL_SH_FKK_RECENT_VTKEY .
  types:
TT_VL_SH_FKK_RECENT_VTKEY type standard table of TS_VL_SH_FKK_RECENT_VTKEY .
  types:
  begin of TS_VL_SH_FM_DEBI_FMPSOIS,
     BEGRU type C length 4,
     KTOKD type C length 4,
     PSOIS type C length 20,
     PSOEA type C length 8,
     KUNNR type C length 10,
  end of TS_VL_SH_FM_DEBI_FMPSOIS .
  types:
TT_VL_SH_FM_DEBI_FMPSOIS type standard table of TS_VL_SH_FM_DEBI_FMPSOIS .
  types:
  begin of TS_VL_SH_FM_KREDI_FMPSOIS,
     BEGRU type C length 4,
     KTOKK type C length 4,
     PSOIS type C length 20,
     PSOEA type C length 8,
     LIFNR type C length 10,
  end of TS_VL_SH_FM_KREDI_FMPSOIS .
  types:
TT_VL_SH_FM_KREDI_FMPSOIS type standard table of TS_VL_SH_FM_KREDI_FMPSOIS .
  types:
  begin of TS_VL_SH_FM_RESERV_ES_AA,
     BUKRS type C length 4,
     CWTFREE type C length 16,
     DOMNAME type C length 30,
     BLTYP type C length 3,
     BLART type C length 2,
     EARMARKEDFUNDS type C length 10,
     EARMARKEDFUNDSITEM type C length 3,
     PTEXT type C length 50,
     WAERS type C length 5,
     SAKNR type C length 10,
     KOSTL type C length 10,
     GEBER type C length 10,
     BUDGET_PD type C length 10,
     FKBER type C length 16,
     GRANTID type C length 20,
     ERLKZ type C length 1,
     BLPKZ type C length 1,
  end of TS_VL_SH_FM_RESERV_ES_AA .
  types:
TT_VL_SH_FM_RESERV_ES_AA type standard table of TS_VL_SH_FM_RESERV_ES_AA .
  types:
  begin of TS_VL_SH_FM_RESERV_ES_HDR,
     BUKRS type C length 4,
     DOMNAME type C length 30,
     MVSTAT type C length 1,
     BLTYP type C length 3,
     BLART type C length 2,
     EARMARKEDFUNDS type C length 10,
     WAERS type C length 5,
     XBLNR type C length 16,
     KTEXT type C length 50,
     KERFAS type C length 12,
     BLDAT type TIMESTAMP,
  end of TS_VL_SH_FM_RESERV_ES_HDR .
  types:
TT_VL_SH_FM_RESERV_ES_HDR type standard table of TS_VL_SH_FM_RESERV_ES_HDR .
  types:
  begin of TS_VL_SH_FM_RESERV_GEN_A,
     DOMNAME type C length 30,
     NPRBUDGET type C length 1,
     BLTYP type C length 3,
     BLART type C length 2,
     BELNR type C length 10,
     BUKRS type C length 4,
     XBLNR type C length 16,
     KTEXT type C length 50,
     MVSTAT type C length 1,
     FMRE_XBLNR2 type C length 70,
     FMRE_XBLNR3 type C length 70,
  end of TS_VL_SH_FM_RESERV_GEN_A .
  types:
TT_VL_SH_FM_RESERV_GEN_A type standard table of TS_VL_SH_FM_RESERV_GEN_A .
  types:
  begin of TS_VL_SH_FM_RESERV_GEN_B,
     NPRBUDGET type C length 1,
     DOMNAME type C length 30,
     BLTYP type C length 3,
     BLART type C length 2,
     BELNR type C length 10,
     BLPOS type C length 3,
     BUKRS type C length 4,
     PTEXT type C length 50,
     MVSTAT type C length 1,
  end of TS_VL_SH_FM_RESERV_GEN_B .
  types:
TT_VL_SH_FM_RESERV_GEN_B type standard table of TS_VL_SH_FM_RESERV_GEN_B .
  types:
  begin of TS_VL_SH_FM_RESERV_GEN_C,
     DOMNAME type C length 30,
     NPRBUDGET type C length 1,
     PRCTR type C length 10,
     BLTYP type C length 3,
     BLART type C length 2,
     BELNR type C length 10,
     BLPOS type C length 3,
     BUKRS type C length 4,
     KOKRS type C length 4,
     WAERS type C length 5,
     SAKNR type C length 10,
     KOSTL type C length 10,
     AUFNR type C length 12,
     MVSTAT type C length 1,
  end of TS_VL_SH_FM_RESERV_GEN_C .
  types:
TT_VL_SH_FM_RESERV_GEN_C type standard table of TS_VL_SH_FM_RESERV_GEN_C .
  types:
  begin of TS_VL_SH_FM_RESERV_GEN_H,
     DOMNAME type C length 30,
     NPRBUDGET type C length 1,
     BLTYP type C length 3,
     BLART type C length 2,
     BELNR type C length 10,
     BLPOS type C length 3,
     BUKRS type C length 4,
     FIKRS type C length 4,
     WAERS type C length 5,
     FIPEX type C length 24,
     FISTL type C length 16,
     GEBER type C length 10,
     FKBER type C length 16,
     GRANT_NBR type C length 20,
     MEASURE type C length 24,
     MVSTAT type C length 1,
  end of TS_VL_SH_FM_RESERV_GEN_H .
  types:
TT_VL_SH_FM_RESERV_GEN_H type standard table of TS_VL_SH_FM_RESERV_GEN_H .
  types:
  begin of TS_VL_SH_FM_RESERV_GEN_K,
     DOMNAME type C length 30,
     NPRBUDGET type C length 1,
     BLTYP type C length 3,
     BLART type C length 2,
     BELNR type C length 10,
     BLPOS type C length 3,
     BUKRS type C length 4,
     WAERS type C length 5,
     ERLKZ type C length 1,
     BLPKZ type C length 1,
     WKAPP type C length 1,
     STATS type C length 1,
     CARRYOV type FLAG,
     CONSUMEKZ type FLAG,
     ACCHANG type FLAG,
     ABGWAERS type FLAG,
     MVSTAT type C length 1,
  end of TS_VL_SH_FM_RESERV_GEN_K .
  types:
TT_VL_SH_FM_RESERV_GEN_K type standard table of TS_VL_SH_FM_RESERV_GEN_K .
  types:
  begin of TS_VL_SH_FM_RESERV_GEN_P,
     DOMNAME type C length 30,
     NPRBUDGET type C length 1,
     PRCTR type C length 10,
     BLTYP type C length 3,
     BLART type C length 2,
     BELNR type C length 10,
     BLPOS type C length 3,
     BUKRS type C length 4,
     KOKRS type C length 4,
     WAERS type C length 5,
     SAKNR type C length 10,
     KOSTL type C length 10,
     AUFNR type C length 12,
     POSID type C length 24,
     MVSTAT type C length 1,
  end of TS_VL_SH_FM_RESERV_GEN_P .
  types:
TT_VL_SH_FM_RESERV_GEN_P type standard table of TS_VL_SH_FM_RESERV_GEN_P .
  types:
  begin of TS_VL_SH_FM_RESERV_GEN_Z,
     CWTFREE type C length 16,
     DOMNAME type C length 30,
     NPRBUDGET type C length 1,
     BLTYP type C length 3,
     BLART type C length 2,
     BELNR type C length 10,
     BLPOS type C length 3,
     BUKRS type C length 4,
     WAERS type C length 5,
     KERFAS type C length 12,
     FDATK type TIMESTAMP,
     BLDAT type TIMESTAMP,
     MVSTAT type C length 1,
  end of TS_VL_SH_FM_RESERV_GEN_Z .
  types:
TT_VL_SH_FM_RESERV_GEN_Z type standard table of TS_VL_SH_FM_RESERV_GEN_Z .
  types:
  begin of TS_VL_SH_FOT_TXA_F4_FRGN_REGIS,
     LANDX type C length 15,
     COMP_CODE type C length 4,
     TAX_COUNTRY type C length 3,
  end of TS_VL_SH_FOT_TXA_F4_FRGN_REGIS .
  types:
TT_VL_SH_FOT_TXA_F4_FRGN_REGIS type standard table of TS_VL_SH_FOT_TXA_F4_FRGN_REGIS .
  types:
  begin of TS_VL_SH_FOT_TXA_F4_TAX_CODE,
     MWART type C length 1,
     DATAB type TIMESTAMP,
     TAXCODE_TEXT type C length 50,
     SPRAS type C length 2,
     XINACT type FLAG,
     MWSKZ type C length 2,
     TEXT1 type C length 50,
     TAX_COUNTRY type C length 3,
     STBUK type C length 4,
     TXDAT type TIMESTAMP,
  end of TS_VL_SH_FOT_TXA_F4_TAX_CODE .
  types:
TT_VL_SH_FOT_TXA_F4_TAX_CODE type standard table of TS_VL_SH_FOT_TXA_F4_TAX_CODE .
  types:
  begin of TS_VL_SH_FSBP_ALIAS,
     ALNAME type C length 80,
     PARTNER type C length 10,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
  end of TS_VL_SH_FSBP_ALIAS .
  types:
TT_VL_SH_FSBP_ALIAS type standard table of TS_VL_SH_FSBP_ALIAS .
  types:
  begin of TS_VL_SH_FSBP_BP_IDNUM,
     IDTYPE type C length 6,
     IDNUM type C length 60,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
  end of TS_VL_SH_FSBP_BP_IDNUM .
  types:
TT_VL_SH_FSBP_BP_IDNUM type standard table of TS_VL_SH_FSBP_BP_IDNUM .
  types:
  begin of TS_VL_SH_FSBP_BUPAG,
     PARTNER type C length 10,
  end of TS_VL_SH_FSBP_BUPAG .
  types:
TT_VL_SH_FSBP_BUPAG type standard table of TS_VL_SH_FSBP_BUPAG .
  types:
  begin of TS_VL_SH_FSHH_MATNR,
     MATNR type C length 40,
     MAKTG type C length 40,
     SPRAS type C length 2,
     FSH_MG_AT1 type C length 10,
     FSH_MG_AT2 type C length 10,
     FSH_MG_AT3 type C length 6,
     FSH_SEASON_YEAR type C length 4,
     FSH_SEASON type C length 10,
     FSH_COLLECTION type C length 10,
     FSH_THEME type C length 10,
  end of TS_VL_SH_FSHH_MATNR .
  types:
TT_VL_SH_FSHH_MATNR type standard table of TS_VL_SH_FSHH_MATNR .
  types:
  begin of TS_VL_SH_GLO_SH_BRNCH_ID,
     BUKRS type C length 4,
     BRANCH type C length 4,
     NAME type C length 30,
  end of TS_VL_SH_GLO_SH_BRNCH_ID .
  types:
TT_VL_SH_GLO_SH_BRNCH_ID type standard table of TS_VL_SH_GLO_SH_BRNCH_ID .
  types:
  begin of TS_VL_SH_GLO_SH_BUPLA_ID,
     BUKRS type C length 4,
     BUPLA type C length 4,
     NAME type C length 30,
  end of TS_VL_SH_GLO_SH_BUPLA_ID .
  types:
TT_VL_SH_GLO_SH_BUPLA_ID type standard table of TS_VL_SH_GLO_SH_BUPLA_ID .
  types:
  begin of TS_VL_SH_HRPADUN_KOSTWO2,
     DATAB type TIMESTAMP,
     DATBI type TIMESTAMP,
     SHORT type C length 12,
     STEXT type C length 40,
     KOSTL type C length 10,
     KOKRS type C length 4,
     BUKRS type C length 4,
     SPRAS type C length 2,
     PERSA type C length 4,
  end of TS_VL_SH_HRPADUN_KOSTWO2 .
  types:
TT_VL_SH_HRPADUN_KOSTWO2 type standard table of TS_VL_SH_HRPADUN_KOSTWO2 .
  types:
  begin of TS_VL_SH_H_AVKOA_FEB,
     KOART type C length 1,
     DDTEXT type C length 60,
     TATYP type C length 4,
  end of TS_VL_SH_H_AVKOA_FEB .
  types:
TT_VL_SH_H_AVKOA_FEB type standard table of TS_VL_SH_H_AVKOA_FEB .
  types:
  begin of TS_VL_SH_H_EKPO,
     EBELN type C length 10,
     EBELP type C length 5,
  end of TS_VL_SH_H_EKPO .
  types:
TT_VL_SH_H_EKPO type standard table of TS_VL_SH_H_EKPO .
  types:
  begin of TS_VL_SH_H_FAGL_SEGM,
     SEGMENT type C length 10,
     NAME type C length 50,
  end of TS_VL_SH_H_FAGL_SEGM .
  types:
TT_VL_SH_H_FAGL_SEGM type standard table of TS_VL_SH_H_FAGL_SEGM .
  types:
  begin of TS_VL_SH_H_FARP_T008,
     ZAHLS type C length 1,
     TEXTL type C length 20,
  end of TS_VL_SH_H_FARP_T008 .
  types:
TT_VL_SH_H_FARP_T008 type standard table of TS_VL_SH_H_FARP_T008 .
  types:
  begin of TS_VL_SH_H_RFCDEST,
     RFCDEST type C length 32,
  end of TS_VL_SH_H_RFCDEST .
  types:
TT_VL_SH_H_RFCDEST type standard table of TS_VL_SH_H_RFCDEST .
  types:
  begin of TS_VL_SH_H_T001,
     BUKRS type C length 4,
     BUTXT type C length 25,
     ORT01 type C length 25,
     WAERS type C length 5,
  end of TS_VL_SH_H_T001 .
  types:
TT_VL_SH_H_T001 type standard table of TS_VL_SH_H_T001 .
  types:
  begin of TS_VL_SH_H_T001S,
     BUKRS type C length 4,
     BUSAB type C length 2,
     SNAME type C length 30,
  end of TS_VL_SH_H_T001S .
  types:
TT_VL_SH_H_T001S type standard table of TS_VL_SH_H_T001S .
  types:
  begin of TS_VL_SH_H_T001W,
     CITY1 type C length 40,
     NAME1 type C length 40,
     SORT2 type C length 20,
     SORT1 type C length 20,
     POST_CODE1 type C length 10,
     MC_CITY1 type C length 25,
     NAME2 type C length 40,
     MC_NAME1 type C length 25,
     NATION type C length 1,
     WERKS type C length 4,
  end of TS_VL_SH_H_T001W .
  types:
TT_VL_SH_H_T001W type standard table of TS_VL_SH_H_T001W .
  types:
  begin of TS_VL_SH_H_T002,
     SPRAS type C length 2,
     SPTXT type C length 16,
  end of TS_VL_SH_H_T002 .
  types:
TT_VL_SH_H_T002 type standard table of TS_VL_SH_H_T002 .
  types:
  begin of TS_VL_SH_H_T003,
     BLART type C length 2,
     LTEXT type C length 20,
  end of TS_VL_SH_H_T003 .
  types:
TT_VL_SH_H_T003 type standard table of TS_VL_SH_H_T003 .
  types:
  begin of TS_VL_SH_H_T004,
     KTOPL type C length 4,
     KTPLT type C length 50,
  end of TS_VL_SH_H_T004 .
  types:
TT_VL_SH_H_T004 type standard table of TS_VL_SH_H_T004 .
  types:
  begin of TS_VL_SH_H_T004V,
     FSTVA type C length 4,
     FSTXT type C length 25,
  end of TS_VL_SH_H_T004V .
  types:
TT_VL_SH_H_T004V type standard table of TS_VL_SH_H_T004V .
  types:
  begin of TS_VL_SH_H_T005,
     LAND1 type C length 3,
     LANDX type C length 15,
     NATIO type C length 15,
  end of TS_VL_SH_H_T005 .
  types:
TT_VL_SH_H_T005 type standard table of TS_VL_SH_H_T005 .
  types:
  begin of TS_VL_SH_H_T006,
     MSEH3 type C length 3,
     MSEHI type C length 3,
     MSEHL type C length 30,
     TXDIM type C length 20,
  end of TS_VL_SH_H_T006 .
  types:
TT_VL_SH_H_T006 type standard table of TS_VL_SH_H_T006 .
  types:
  begin of TS_VL_SH_H_T012,
     BANKA type C length 60,
     ORT01 type C length 35,
     NAME1 type C length 30,
     BUKRS type C length 4,
     HBKID type C length 5,
     BANKS type C length 3,
     BANKL type C length 15,
  end of TS_VL_SH_H_T012 .
  types:
TT_VL_SH_H_T012 type standard table of TS_VL_SH_H_T012 .
  types:
  begin of TS_VL_SH_H_T012K,
     BUKRS type C length 4,
     HBKID type C length 5,
     HKTID type C length 5,
     TEXT1 type C length 50,
  end of TS_VL_SH_H_T012K .
  types:
TT_VL_SH_H_T012K type standard table of TS_VL_SH_H_T012K .
  types:
  begin of TS_VL_SH_H_T012K_BAM,
     SPRAS type C length 2,
     BUKRS type C length 4,
     HBKID type C length 5,
     HKTID type C length 5,
     DESCRIPTION type C length 60,
     BANKACCOUNTSTATUSNAME type C length 60,
  end of TS_VL_SH_H_T012K_BAM .
  types:
TT_VL_SH_H_T012K_BAM type standard table of TS_VL_SH_H_T012K_BAM .
  types:
  begin of TS_VL_SH_H_T014,
     KKBER type C length 4,
     KKBTX type C length 35,
  end of TS_VL_SH_H_T014 .
  types:
TT_VL_SH_H_T014 type standard table of TS_VL_SH_H_T014 .
  types:
  begin of TS_VL_SH_H_T015L,
     LZBKZ type C length 3,
     LVAWV type C length 3,
     ZWCK1 type C length 70,
  end of TS_VL_SH_H_T015L .
  types:
TT_VL_SH_H_T015L type standard table of TS_VL_SH_H_T015L .
  types:
  begin of TS_VL_SH_H_T016,
     BRSCH type C length 4,
     BRTXT type C length 20,
  end of TS_VL_SH_H_T016 .
  types:
TT_VL_SH_H_T016 type standard table of TS_VL_SH_H_T016 .
  types:
  begin of TS_VL_SH_H_T023,
     MATKL type C length 9,
     WGBEZ type C length 20,
     WGBEZ60 type C length 60,
  end of TS_VL_SH_H_T023 .
  types:
TT_VL_SH_H_T023 type standard table of TS_VL_SH_H_T023 .
  types:
  begin of TS_VL_SH_H_T028D,
     VGINT type C length 4,
     TXT20 type C length 40,
  end of TS_VL_SH_H_T028D .
  types:
TT_VL_SH_H_T028D type standard table of TS_VL_SH_H_T028D .
  types:
  begin of TS_VL_SH_H_T028G,
     VGTYP type C length 8,
     VGEXT type C length 27,
     VOZPM type C length 1,
  end of TS_VL_SH_H_T028G .
  types:
TT_VL_SH_H_T028G type standard table of TS_VL_SH_H_T028G .
  types:
  begin of TS_VL_SH_H_T028H,
     VTYPM type C length 1,
     VGMAN type C length 4,
     VOZPM type C length 1,
     TXT20 type C length 40,
  end of TS_VL_SH_H_T028H .
  types:
TT_VL_SH_H_T028H type standard table of TS_VL_SH_H_T028H .
  types:
  begin of TS_VL_SH_H_T040,
     MSCHL type C length 1,
     TEXT1 type C length 50,
  end of TS_VL_SH_H_T040 .
  types:
TT_VL_SH_H_T040 type standard table of TS_VL_SH_H_T040 .
  types:
  begin of TS_VL_SH_H_T040S,
     MANSP type C length 1,
     TEXT1 type C length 50,
  end of TS_VL_SH_H_T040S .
  types:
TT_VL_SH_H_T040S type standard table of TS_VL_SH_H_T040S .
  types:
  begin of TS_VL_SH_H_T042Z,
     TEXT1 type C length 30,
     LAND1 type C length 3,
     ZLSCH type C length 1,
     TEXT2 type C length 30,
  end of TS_VL_SH_H_T042Z .
  types:
TT_VL_SH_H_T042Z type standard table of TS_VL_SH_H_T042Z .
  types:
  begin of TS_VL_SH_H_T047M,
     BUKRS type C length 4,
     MABER type C length 2,
     TEXT1 type C length 50,
  end of TS_VL_SH_H_T047M .
  types:
TT_VL_SH_H_T047M type standard table of TS_VL_SH_H_T047M .
  types:
  begin of TS_VL_SH_H_T053R,
     XAUSB type FLAG,
     BUKRS type C length 4,
     RSTGR type C length 3,
     TXT20 type C length 20,
     TXT40 type C length 40,
  end of TS_VL_SH_H_T053R .
  types:
TT_VL_SH_H_T053R type standard table of TS_VL_SH_H_T053R .
  types:
  begin of TS_VL_SH_H_T074U,
     KOART type C length 1,
     UMSKZ type C length 1,
     LTEXT type C length 30,
  end of TS_VL_SH_H_T074U .
  types:
TT_VL_SH_H_T074U type standard table of TS_VL_SH_H_T074U .
  types:
  begin of TS_VL_SH_H_T077D,
     KTOKD type C length 4,
     NUMKR type C length 2,
     XCPDS type FLAG,
     TXT30 type C length 30,
  end of TS_VL_SH_H_T077D .
  types:
TT_VL_SH_H_T077D type standard table of TS_VL_SH_H_T077D .
  types:
  begin of TS_VL_SH_H_T077K,
     KTOKK type C length 4,
     NUMKR type C length 2,
     XCPDS type FLAG,
     TXT30 type C length 30,
  end of TS_VL_SH_H_T077K .
  types:
TT_VL_SH_H_T077K type standard table of TS_VL_SH_H_T077K .
  types:
  begin of TS_VL_SH_H_T077S,
     KTOPL type C length 4,
     KTOKS type C length 4,
     TXT30 type C length 30,
  end of TS_VL_SH_H_T077S .
  types:
TT_VL_SH_H_T077S type standard table of TS_VL_SH_H_T077S .
  types:
  begin of TS_VL_SH_H_T151,
     KDGRP type C length 2,
     KTEXT type C length 20,
  end of TS_VL_SH_H_T151 .
  types:
TT_VL_SH_H_T151 type standard table of TS_VL_SH_H_T151 .
  types:
  begin of TS_VL_SH_H_T171,
     BZIRK type C length 6,
     BZTXT type C length 20,
  end of TS_VL_SH_H_T171 .
  types:
TT_VL_SH_H_T171 type standard table of TS_VL_SH_H_T171 .
  types:
  begin of TS_VL_SH_H_T685,
     KVEWE type C length 1,
     KAPPL type C length 2,
     KSCHL type C length 4,
     VTEXT type C length 20,
  end of TS_VL_SH_H_T685 .
  types:
TT_VL_SH_H_T685 type standard table of TS_VL_SH_H_T685 .
  types:
  begin of TS_VL_SH_H_T856,
     TRTYP type C length 3,
     TXT type C length 20,
  end of TS_VL_SH_H_T856 .
  types:
TT_VL_SH_H_T856 type standard table of TS_VL_SH_H_T856 .
  types:
  begin of TS_VL_SH_H_T880,
     RCOMP type C length 6,
     NAME1 type C length 30,
     NAME2 type C length 30,
     CNTRY type C length 3,
     CURR type C length 5,
  end of TS_VL_SH_H_T880 .
  types:
TT_VL_SH_H_T880 type standard table of TS_VL_SH_H_T880 .
  types:
  begin of TS_VL_SH_H_T881,
     RLDNR type C length 2,
     NAME type C length 30,
  end of TS_VL_SH_H_T881 .
  types:
TT_VL_SH_H_T881 type standard table of TS_VL_SH_H_T881 .
  types:
  begin of TS_VL_SH_H_T8JF,
     BUKRS type C length 4,
     VNAME type C length 6,
     EGRUP type C length 3,
     EGTXT type C length 35,
  end of TS_VL_SH_H_T8JF .
  types:
TT_VL_SH_H_T8JF type standard table of TS_VL_SH_H_T8JF .
  types:
  begin of TS_VL_SH_H_T8JJ,
     BUKRS type C length 4,
     RECID type C length 2,
     TTEXT type C length 35,
  end of TS_VL_SH_H_T8JJ .
  types:
TT_VL_SH_H_T8JJ type standard table of TS_VL_SH_H_T8JJ .
  types:
  begin of TS_VL_SH_H_T8JV,
     BUKRS type C length 4,
     VNAME type C length 6,
     VTEXT type C length 35,
  end of TS_VL_SH_H_T8JV .
  types:
TT_VL_SH_H_T8JV type standard table of TS_VL_SH_H_T8JV .
  types:
  begin of TS_VL_SH_H_TATYP,
     TATYP type C length 4,
     INTAG type C length 3,
     OI_FIND_ALG type C length 30,
     TEXT type C length 60,
  end of TS_VL_SH_H_TATYP .
  types:
TT_VL_SH_H_TATYP type standard table of TS_VL_SH_H_TATYP .
  types:
  begin of TS_VL_SH_H_TGSB,
     GSBER type C length 4,
     GTEXT type C length 30,
  end of TS_VL_SH_H_TGSB .
  types:
TT_VL_SH_H_TGSB type standard table of TS_VL_SH_H_TGSB .
  types:
  begin of TS_VL_SH_H_TKA01,
     KOKRS type C length 4,
     BEZEI type C length 25,
     WAERS type C length 5,
     KTOPL type C length 4,
     LMONA type C length 2,
     KHINR type C length 12,
  end of TS_VL_SH_H_TKA01 .
  types:
TT_VL_SH_H_TKA01 type standard table of TS_VL_SH_H_TKA01 .
  types:
  begin of TS_VL_SH_H_TNLS,
     NIELS type C length 2,
     BEZEI type C length 20,
  end of TS_VL_SH_H_TNLS .
  types:
TT_VL_SH_H_TNLS type standard table of TS_VL_SH_H_TNLS .
  types:
  begin of TS_VL_SH_H_TSOTD,
     OBJTP type C length 3,
     TPDES type C length 26,
  end of TS_VL_SH_H_TSOTD .
  types:
TT_VL_SH_H_TSOTD type standard table of TS_VL_SH_H_TSOTD .
  types:
  begin of TS_VL_SH_H_TSPA,
     HIDE type FLAG,
     SPART type C length 2,
     VTEXT type C length 20,
  end of TS_VL_SH_H_TSPA .
  types:
TT_VL_SH_H_TSPA type standard table of TS_VL_SH_H_TSPA .
  types:
  begin of TS_VL_SH_H_TTXJ,
     KALSM type C length 6,
     TXJCD type C length 15,
     TEXT1 type C length 50,
  end of TS_VL_SH_H_TTXJ .
  types:
TT_VL_SH_H_TTXJ type standard table of TS_VL_SH_H_TTXJ .
  types:
  begin of TS_VL_SH_H_TVBO,
     BONUS type C length 2,
     VTEXT type C length 20,
  end of TS_VL_SH_H_TVBO .
  types:
TT_VL_SH_H_TVBO type standard table of TS_VL_SH_H_TVBO .
  types:
  begin of TS_VL_SH_H_TVBUR,
     HIDE type FLAG,
     VKBUR type C length 4,
     BEZEI type C length 20,
  end of TS_VL_SH_H_TVBUR .
  types:
TT_VL_SH_H_TVBUR type standard table of TS_VL_SH_H_TVBUR .
  types:
  begin of TS_VL_SH_H_TVFK,
     FKART type C length 4,
     VTEXT type C length 40,
  end of TS_VL_SH_H_TVFK .
  types:
TT_VL_SH_H_TVFK type standard table of TS_VL_SH_H_TVFK .
  types:
  begin of TS_VL_SH_H_TVKGR,
     HIDE type FLAG,
     VKGRP type C length 3,
     BEZEI type C length 20,
  end of TS_VL_SH_H_TVKGR .
  types:
TT_VL_SH_H_TVKGR type standard table of TS_VL_SH_H_TVKGR .
  types:
  begin of TS_VL_SH_H_TVKO,
     HIDE type FLAG,
     VKORG type C length 4,
     VTEXT type C length 20,
  end of TS_VL_SH_H_TVKO .
  types:
TT_VL_SH_H_TVKO type standard table of TS_VL_SH_H_TVKO .
  types:
  begin of TS_VL_SH_H_TVTW,
     HIDE type FLAG,
     VTWEG type C length 2,
     VTEXT type C length 20,
  end of TS_VL_SH_H_TVTW .
  types:
TT_VL_SH_H_TVTW type standard table of TS_VL_SH_H_TVTW .
  types:
  begin of TS_VL_SH_H_VIBEBE,
     SBERI type C length 10,
     XBERIBZ type C length 50,
     JLOESCH type C length 1,
  end of TS_VL_SH_H_VIBEBE .
  types:
TT_VL_SH_H_VIBEBE type standard table of TS_VL_SH_H_VIBEBE .
  types:
  begin of TS_VL_SH_JVH_KOSTG,
     KOKRS type C length 4,
     KOSTL type C length 10,
     BUKRS type C length 4,
     KTEXT type C length 20,
     VNAME type C length 6,
     RECID type C length 2,
     ETYPE type C length 3,
     JV_OTYPE type C length 4,
     JV_JIBCL type C length 3,
     JV_JIBSA type C length 5,
  end of TS_VL_SH_JVH_KOSTG .
  types:
TT_VL_SH_JVH_KOSTG type standard table of TS_VL_SH_JVH_KOSTG .
  types:
  begin of TS_VL_SH_JVH_VPTNR,
     PARTN type C length 10,
     BUKRS type C length 4,
     VNAME type C length 6,
     EGRUP type C length 3,
  end of TS_VL_SH_JVH_VPTNR .
  types:
TT_VL_SH_JVH_VPTNR type standard table of TS_VL_SH_JVH_VPTNR .
  types:
  begin of TS_VL_SH_KOSTD,
     DATAB type TIMESTAMP,
     DATBI type TIMESTAMP,
     KOSTL type C length 10,
     KOKRS type C length 4,
     BUKRS type C length 4,
     KOSAR type C length 1,
     VERAK type C length 20,
     VERAK_USER type C length 12,
     MCTXT type C length 20,
     SPRAS type C length 2,
  end of TS_VL_SH_KOSTD .
  types:
TT_VL_SH_KOSTD type standard table of TS_VL_SH_KOSTD .
  types:
  begin of TS_VL_SH_KOSTN,
     DATAB type TIMESTAMP,
     DATBI type TIMESTAMP,
     KOSTL type C length 10,
     KOKRS type C length 4,
     BUKRS type C length 4,
     KOSAR type C length 1,
     VERAK type C length 20,
     VERAK_USER type C length 12,
     MCTXT type C length 20,
     SPRAS type C length 2,
  end of TS_VL_SH_KOSTN .
  types:
TT_VL_SH_KOSTN type standard table of TS_VL_SH_KOSTN .
  types:
  begin of TS_VL_SH_KOSTS,
     DATAB type TIMESTAMP,
     DATBI type TIMESTAMP,
     MCTXT type C length 20,
     SPRAS type C length 2,
     KOKRS type C length 4,
     BUKRS type C length 4,
     KOSAR type C length 1,
     KOSTL type C length 10,
  end of TS_VL_SH_KOSTS .
  types:
TT_VL_SH_KOSTS type standard table of TS_VL_SH_KOSTS .
  types:
  begin of TS_VL_SH_KREDA,
     BEGRU type C length 4,
     KTOKK type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     LIFNR type C length 10,
     LOEVM type FLAG,
  end of TS_VL_SH_KREDA .
  types:
TT_VL_SH_KREDA type standard table of TS_VL_SH_KREDA .
  types:
  begin of TS_VL_SH_KREDE,
     BEGRU type C length 4,
     KTOKK type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     LIFNR type C length 10,
     EKORG type C length 4,
     BOLRE type FLAG,
     LOEVM type FLAG,
  end of TS_VL_SH_KREDE .
  types:
TT_VL_SH_KREDE type standard table of TS_VL_SH_KREDE .
  types:
  begin of TS_VL_SH_KREDI,
     BEGRU type C length 4,
     KTOKK type C length 4,
     LAND1 type C length 3,
     MCOD3 type C length 25,
     SORTL type C length 10,
     MCOD1 type C length 25,
     LIFNR type C length 10,
     BUKRS type C length 4,
  end of TS_VL_SH_KREDI .
  types:
TT_VL_SH_KREDI type standard table of TS_VL_SH_KREDI .
  types:
  begin of TS_VL_SH_KREDK,
     BEGRU type C length 4,
     KTOKK type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     LIFNR type C length 10,
     BUKRS type C length 4,
     LOEVM type FLAG,
  end of TS_VL_SH_KREDK .
  types:
TT_VL_SH_KREDK type standard table of TS_VL_SH_KREDK .
  types:
  begin of TS_VL_SH_KREDL,
     BEGRU type C length 4,
     KTOKK type C length 4,
     LAND1 type C length 3,
     SORTL type C length 10,
     MCOD1 type C length 25,
     MCOD3 type C length 25,
     LIFNR type C length 10,
  end of TS_VL_SH_KREDL .
  types:
TT_VL_SH_KREDL type standard table of TS_VL_SH_KREDL .
  types:
  begin of TS_VL_SH_KREDM,
     BEGRU type C length 4,
     MATNR type C length 40,
     IDNLF type C length 35,
     EIORG type C length 4,
     LIFNR type C length 10,
     INFNR type C length 10,
     ESOKZ type C length 1,
     EWERK type C length 4,
  end of TS_VL_SH_KREDM .
  types:
TT_VL_SH_KREDM type standard table of TS_VL_SH_KREDM .
  types:
  begin of TS_VL_SH_KREDP,
     BEGRU type C length 4,
     KTOKK type C length 4,
     LIFNR type C length 10,
     PERNR type C length 8,
     MCOD1 type C length 25,
     BUKRS type C length 4,
  end of TS_VL_SH_KREDP .
  types:
TT_VL_SH_KREDP type standard table of TS_VL_SH_KREDP .
  types:
  begin of TS_VL_SH_KREDT,
     BEGRU type C length 4,
     KTOKK type C length 4,
     STCD1 type C length 16,
     STCD2 type C length 11,
     STCD3 type C length 18,
     STCD4 type C length 18,
     STCD5 type C length 60,
     STCD6 type C length 20,
     STCEG type C length 20,
     LAND1 type C length 3,
     MCOD1 type C length 25,
     LIFNR type C length 10,
  end of TS_VL_SH_KREDT .
  types:
TT_VL_SH_KREDT type standard table of TS_VL_SH_KREDT .
  types:
  begin of TS_VL_SH_KREDW,
     BEGRU type C length 4,
     KTOKK type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     WERKS type C length 4,
     LIFNR type C length 10,
  end of TS_VL_SH_KREDW .
  types:
TT_VL_SH_KREDW type standard table of TS_VL_SH_KREDW .
  types:
  begin of TS_VL_SH_KREDX,
     CITY1 type C length 40,
     COUNTRY type C length 3,
     HOUSE_NUM1 type C length 10,
     MC_CITY1 type C length 25,
     MC_NAME type C length 25,
     MC_STREET type C length 25,
     NAME type C length 40,
     POST_CODE1 type C length 10,
     POST_CODE2 type C length 10,
     PO_BOX type C length 10,
     REGION type C length 3,
     SORT1 type C length 20,
     SORT2 type C length 20,
     STREET type C length 60,
     LIFNR type C length 10,
  end of TS_VL_SH_KREDX .
  types:
TT_VL_SH_KREDX type standard table of TS_VL_SH_KREDX .
  types:
  begin of TS_VL_SH_KREDY,
     LIFNR type C length 10,
  end of TS_VL_SH_KREDY .
  types:
TT_VL_SH_KREDY type standard table of TS_VL_SH_KREDY .
  types:
  begin of TS_VL_SH_KRED_ES_ADVANCED,
     OBJECT_TYPE_ID type C length 20,
     REQUEST type C length 32,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type FLAG,
     LIFNR type C length 10,
     NAME1 type C length 35,
     NAME2 type C length 40,
     COUNTRY type C length 3,
     CITY1 type C length 40,
     POST_CODE1 type C length 10,
     STREET type C length 60,
     HOUSE_NUM1 type C length 10,
  end of TS_VL_SH_KRED_ES_ADVANCED .
  types:
TT_VL_SH_KRED_ES_ADVANCED type standard table of TS_VL_SH_KRED_ES_ADVANCED .
  types:
  begin of TS_VL_SH_KRED_ES_SIMPLE,
     CITY1 type C length 40,
     COUNTRY type C length 3,
     HOUSE_NUM1 type C length 10,
     LIFNR type C length 10,
     NAME1 type C length 35,
     NAME2 type C length 40,
     OBJECT_TYPE_ID type C length 20,
     POST_CODE1 type C length 10,
     REQUEST type C length 32,
     STREET type C length 60,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type FLAG,
  end of TS_VL_SH_KRED_ES_SIMPLE .
  types:
TT_VL_SH_KRED_ES_SIMPLE type standard table of TS_VL_SH_KRED_ES_SIMPLE .
  types:
  begin of TS_VL_SH_LARTN,
     DATAB type TIMESTAMP,
     DATBI type TIMESTAMP,
     LSTAR type C length 6,
     KOKRS type C length 4,
     MCTXT type C length 20,
     SPRAS type C length 2,
  end of TS_VL_SH_LARTN .
  types:
TT_VL_SH_LARTN type standard table of TS_VL_SH_LARTN .
  types:
  begin of TS_VL_SH_LARTS,
     DATAB type TIMESTAMP,
     DATBI type TIMESTAMP,
     MCTXT type C length 20,
     SPRAS type C length 2,
     KOKRS type C length 4,
     LATYP type C length 1,
     LSTAR type C length 6,
  end of TS_VL_SH_LARTS .
  types:
TT_VL_SH_LARTS type standard table of TS_VL_SH_LARTS .
  types:
  begin of TS_VL_SH_MAT0M,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT0M .
  types:
TT_VL_SH_MAT0M type standard table of TS_VL_SH_MAT0M .
  types:
  begin of TS_VL_SH_MAT1A,
     BISMT type C length 40,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT1A .
  types:
TT_VL_SH_MAT1A type standard table of TS_VL_SH_MAT1A .
  types:
  begin of TS_VL_SH_MAT1B,
     MAKTG type C length 40,
     MAST_WERKS type C length 4,
     STLAN type C length 1,
     MATNR type C length 40,
     STLAL type C length 2,
     SPRAS type C length 2,
  end of TS_VL_SH_MAT1B .
  types:
TT_VL_SH_MAT1B type standard table of TS_VL_SH_MAT1B .
  types:
  begin of TS_VL_SH_MAT1C,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT1C .
  types:
TT_VL_SH_MAT1C type standard table of TS_VL_SH_MAT1C .
  types:
  begin of TS_VL_SH_MAT1E,
     KUNNR type C length 10,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT1E .
  types:
TT_VL_SH_MAT1E type standard table of TS_VL_SH_MAT1E .
  types:
  begin of TS_VL_SH_MAT1F,
     MAKTG type C length 40,
     FHM_FGRU1 type C length 4,
     FHM_FGRU2 type C length 4,
     SPRAS type C length 2,
     MATNR type C length 40,
     WERKS type C length 4,
  end of TS_VL_SH_MAT1F .
  types:
TT_VL_SH_MAT1F type standard table of TS_VL_SH_MAT1F .
  types:
  begin of TS_VL_SH_MAT1H,
     PRDHA type C length 18,
     VKORG type C length 4,
     VTWEG type C length 2,
     MATNR type C length 40,
     SPRAS type C length 2,
     MAKTG type C length 40,
  end of TS_VL_SH_MAT1H .
  types:
TT_VL_SH_MAT1H type standard table of TS_VL_SH_MAT1H .
  types:
  begin of TS_VL_SH_MAT1I,
     IDNLF type C length 35,
     LIFNR type C length 10,
     MATNR type C length 40,
     MAKTG type C length 40,
     SPRAS type C length 2,
  end of TS_VL_SH_MAT1I .
  types:
TT_VL_SH_MAT1I type standard table of TS_VL_SH_MAT1I .
  types:
  begin of TS_VL_SH_MAT1J,
     ATTYP type C length 2,
     MATKL type C length 9,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT1J .
  types:
TT_VL_SH_MAT1J type standard table of TS_VL_SH_MAT1J .
  types:
  begin of TS_VL_SH_MAT1L,
     MATKL type C length 9,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT1L .
  types:
TT_VL_SH_MAT1L type standard table of TS_VL_SH_MAT1L .
  types:
  begin of TS_VL_SH_MAT1MPN,
     MATNR_HTN type C length 40,
     TEXT_HTN type C length 40,
     MATNR_B type C length 40,
     MFRPN type C length 40,
     MFRNR type C length 10,
     SPRAS type C length 2,
  end of TS_VL_SH_MAT1MPN .
  types:
TT_VL_SH_MAT1MPN type standard table of TS_VL_SH_MAT1MPN .
  types:
  begin of TS_VL_SH_MAT1N,
     EAN11 type C length 18,
     MATNR type C length 40,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MEINH type C length 3,
     HPEAN type FLAG,
  end of TS_VL_SH_MAT1N .
  types:
TT_VL_SH_MAT1N type standard table of TS_VL_SH_MAT1N .
  types:
  begin of TS_VL_SH_MAT1P,
     PRODH type C length 18,
     VKORG type C length 4,
     VTWEG type C length 2,
     MATNR type C length 40,
     SPRAS type C length 2,
     MAKTG type C length 40,
  end of TS_VL_SH_MAT1P .
  types:
TT_VL_SH_MAT1P type standard table of TS_VL_SH_MAT1P .
  types:
  begin of TS_VL_SH_MAT1R,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
     MAPL_WERKS type C length 4,
     PLNTY type C length 1,
     PLNNR type C length 8,
     PLNAL type C length 2,
     DATUV type TIMESTAMP,
  end of TS_VL_SH_MAT1R .
  types:
TT_VL_SH_MAT1R type standard table of TS_VL_SH_MAT1R .
  types:
  begin of TS_VL_SH_MAT1S,
     MAKTG type C length 40,
     SPRAS type C length 2,
     VKORG type C length 4,
     VTWEG type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT1S .
  types:
TT_VL_SH_MAT1S type standard table of TS_VL_SH_MAT1S .
  types:
  begin of TS_VL_SH_MAT1T,
     MTART type C length 4,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
  end of TS_VL_SH_MAT1T .
  types:
TT_VL_SH_MAT1T type standard table of TS_VL_SH_MAT1T .
  types:
  begin of TS_VL_SH_MAT1V,
     PRVBE type C length 10,
     MATNR type C length 40,
     WERKS type C length 4,
     MAKTG type C length 40,
     SPRAS type C length 2,
  end of TS_VL_SH_MAT1V .
  types:
TT_VL_SH_MAT1V type standard table of TS_VL_SH_MAT1V .
  types:
  begin of TS_VL_SH_MAT1W,
     MAKTG type C length 40,
     SPRAS type C length 2,
     MATNR type C length 40,
     WERKS type C length 4,
  end of TS_VL_SH_MAT1W .
  types:
TT_VL_SH_MAT1W type standard table of TS_VL_SH_MAT1W .
  types:
  begin of TS_VL_SH_MAT1_ESH_TREX_BASIC,
     CDS_ENTITY_CHAR_1_TO_19 type C length 30,
     PRODUCTEXTERNALID type C length 40,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
     PRODUCT type C length 40,
     PRODUCTOLDID type C length 40,
     PRODUCTSTANDARDID type C length 18,
     PRODUCTTYPE type C length 4,
     PRODUCTNAME type C length 40,
     PRODUCTGROUP type C length 9,
     CREATEDBYUSER type C length 12,
     LASTCHANGEDBYUSER type C length 12,
     PLANT type C length 4,
  end of TS_VL_SH_MAT1_ESH_TREX_BASIC .
  types:
TT_VL_SH_MAT1_ESH_TREX_BASIC type standard table of TS_VL_SH_MAT1_ESH_TREX_BASIC .
  types:
  begin of TS_VL_SH_MAT1_TREX_ADVANCED,
     BUSINESS_OBJECT type C length 10,
     DESCRIPTION type C length 40,
     OBJECT_ID type C length 40,
     OBJECT_TYPE type C length 10,
     STD_DESCR type C length 18,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
     EXTERNAL_KEY type C length 40,
     OLD_MAT_NO type C length 40,
     EAN_UPC type C length 18,
     MATL_TYPE type C length 4,
     MATL_CAT type C length 2,
     MAKTG type C length 40,
     PROD_HIER type C length 18,
     MATL_GROUP type C length 9,
     PLANT type C length 4,
     SALESORG type C length 4,
     DISTR_CHAN type C length 2,
     DIVISION type C length 2,
     DEL_FLAG type FLAG,
  end of TS_VL_SH_MAT1_TREX_ADVANCED .
  types:
TT_VL_SH_MAT1_TREX_ADVANCED type standard table of TS_VL_SH_MAT1_TREX_ADVANCED .
  types:
  begin of TS_VL_SH_MAT1_TREX_SIMPLE,
     BUSINESS_OBJECT type C length 10,
     DESCRIPTION type C length 40,
     MATL_CAT type C length 2,
     MATL_GROUP type C length 9,
     MATL_TYPE type C length 4,
     OBJECT_ID type C length 40,
     OBJECT_TYPE type C length 10,
     PROD_HIER type C length 18,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_MAT1_TREX_SIMPLE .
  types:
TT_VL_SH_MAT1_TREX_SIMPLE type standard table of TS_VL_SH_MAT1_TREX_SIMPLE .
  types:
  begin of TS_VL_SH_MAT2MPN,
     MATNR_B type C length 40,
     MATNR_HTN type C length 40,
     MFRPN type C length 40,
     MFRNR type C length 10,
     WERKS type C length 4,
     DATUV type TIMESTAMP,
     DATUB type TIMESTAMP,
     REVLV type C length 2,
     AMPSP type C length 4,
  end of TS_VL_SH_MAT2MPN .
  types:
TT_VL_SH_MAT2MPN type standard table of TS_VL_SH_MAT2MPN .
  types:
  begin of TS_VL_SH_MAT3MPN,
     IMATN type C length 40,
     MATNR type C length 40,
     MFRPN type C length 40,
     MFRNR type C length 10,
     EMNFR type C length 10,
  end of TS_VL_SH_MAT3MPN .
  types:
TT_VL_SH_MAT3MPN type standard table of TS_VL_SH_MAT3MPN .
  types:
  begin of TS_VL_SH_MAT4MPN,
     MATNR type C length 40,
     MRPGR type C length 10,
     BERID type C length 10,
     WERKS type C length 4,
     LMATN type C length 40,
  end of TS_VL_SH_MAT4MPN .
  types:
TT_VL_SH_MAT4MPN type standard table of TS_VL_SH_MAT4MPN .
  types:
  begin of TS_VL_SH_MAT5MPN,
     MATNR type C length 40,
     MFRPN type C length 40,
     SUBSTMAT type C length 40,
     EXCHTYP type C length 4,
  end of TS_VL_SH_MAT5MPN .
  types:
TT_VL_SH_MAT5MPN type standard table of TS_VL_SH_MAT5MPN .
  types:
  begin of TS_VL_SH_MAT6MPN,
     MATNR_HTN type C length 40,
     TEXT_HTN type C length 40,
     MATNR_B type C length 40,
     MFRPN type C length 40,
     MFRNR type C length 10,
     SPRAS type C length 2,
  end of TS_VL_SH_MAT6MPN .
  types:
TT_VL_SH_MAT6MPN type standard table of TS_VL_SH_MAT6MPN .
  types:
  begin of TS_VL_SH_MEKKA,
     ANLN1 type C length 12,
     ANLN2 type C length 4,
     BUKRS type C length 4,
     BSTYP type C length 1,
     EKORG type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
     ZEKKN type C length 2,
  end of TS_VL_SH_MEKKA .
  types:
TT_VL_SH_MEKKA type standard table of TS_VL_SH_MEKKA .
  types:
  begin of TS_VL_SH_MEKKB,
     BEDNR type C length 10,
     BSTYP type C length 1,
     BSART type C length 4,
     EKORG type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
  end of TS_VL_SH_MEKKB .
  types:
TT_VL_SH_MEKKB type standard table of TS_VL_SH_MEKKB .
  types:
  begin of TS_VL_SH_MEKKC,
     BSTYP type C length 1,
     BEDAT type TIMESTAMP,
     EBELN type C length 10,
  end of TS_VL_SH_MEKKC .
  types:
TT_VL_SH_MEKKC type standard table of TS_VL_SH_MEKKC .
  types:
  begin of TS_VL_SH_MEKKD,
     BSTYP type C length 1,
     BEDAT type TIMESTAMP,
     EBELN type C length 10,
  end of TS_VL_SH_MEKKD .
  types:
TT_VL_SH_MEKKD type standard table of TS_VL_SH_MEKKD .
  types:
  begin of TS_VL_SH_MEKKE,
     BANFN type C length 10,
     BNFPO type C length 5,
     EBELN type C length 10,
     EBELP type C length 5,
     ETENR type C length 4,
  end of TS_VL_SH_MEKKE .
  types:
TT_VL_SH_MEKKE type standard table of TS_VL_SH_MEKKE .
  types:
  begin of TS_VL_SH_MEKKG,
     AUFNR type C length 12,
     BSTYP type C length 1,
     EKORG type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
     ZEKKN type C length 2,
  end of TS_VL_SH_MEKKG .
  types:
TT_VL_SH_MEKKG type standard table of TS_VL_SH_MEKKG .
  types:
  begin of TS_VL_SH_MEKKH,
     WERKS type C length 4,
     MATKL type C length 9,
     EKORG type C length 4,
     EBELN type C length 10,
     TXZ01 type C length 40,
  end of TS_VL_SH_MEKKH .
  types:
TT_VL_SH_MEKKH type standard table of TS_VL_SH_MEKKH .
  types:
  begin of TS_VL_SH_MEKKI,
     WERKS type C length 4,
     MATKL type C length 9,
     EKORG type C length 4,
     EBELN type C length 10,
     TXZ01 type C length 40,
     EBELP type C length 5,
  end of TS_VL_SH_MEKKI .
  types:
TT_VL_SH_MEKKI type standard table of TS_VL_SH_MEKKI .
  types:
  begin of TS_VL_SH_MEKKK,
     KOSTL type C length 10,
     KOKRS type C length 4,
     BSTYP type C length 1,
     EKORG type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
     ZEKKN type C length 2,
  end of TS_VL_SH_MEKKK .
  types:
TT_VL_SH_MEKKK type standard table of TS_VL_SH_MEKKK .
  types:
  begin of TS_VL_SH_MEKKL,
     LIFNR type C length 10,
     EKORG type C length 4,
     EKGRP type C length 3,
     BEDAT type TIMESTAMP,
     BSTYP type C length 1,
     BSART type C length 4,
     EBELN type C length 10,
  end of TS_VL_SH_MEKKL .
  types:
TT_VL_SH_MEKKL type standard table of TS_VL_SH_MEKKL .
  types:
  begin of TS_VL_SH_MEKKM,
     MATNR type C length 40,
     WERKS type C length 4,
     BSTYP type C length 1,
     BSART type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
  end of TS_VL_SH_MEKKM .
  types:
TT_VL_SH_MEKKM type standard table of TS_VL_SH_MEKKM .
  types:
  begin of TS_VL_SH_MEKKN,
     NPLNR type C length 12,
     AUFPL type C length 10,
     APLZL type C length 8,
     BSTYP type C length 1,
     EKORG type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
     ZEKKN type C length 2,
  end of TS_VL_SH_MEKKN .
  types:
TT_VL_SH_MEKKN type standard table of TS_VL_SH_MEKKN .
  types:
  begin of TS_VL_SH_MEKKP,
     PS_PSP_PNR type C length 24,
     POSID type C length 24,
     BSTYP type C length 1,
     EKORG type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
     ZEKKN type C length 2,
  end of TS_VL_SH_MEKKP .
  types:
TT_VL_SH_MEKKP type standard table of TS_VL_SH_MEKKP .
  types:
  begin of TS_VL_SH_MEKKS,
     SUBMI type C length 10,
     EKORG type C length 4,
     EBELN type C length 10,
  end of TS_VL_SH_MEKKS .
  types:
TT_VL_SH_MEKKS type standard table of TS_VL_SH_MEKKS .
  types:
  begin of TS_VL_SH_MEKKT,
     BSTYP type C length 1,
     BEDAT type TIMESTAMP,
     EBELN type C length 10,
  end of TS_VL_SH_MEKKT .
  types:
TT_VL_SH_MEKKT type standard table of TS_VL_SH_MEKKT .
  types:
  begin of TS_VL_SH_MEKKU,
     BSTYP type C length 1,
     BEDAT type TIMESTAMP,
     EBELN type C length 10,
  end of TS_VL_SH_MEKKU .
  types:
TT_VL_SH_MEKKU type standard table of TS_VL_SH_MEKKU .
  types:
  begin of TS_VL_SH_MEKKV,
     VBELN type C length 10,
     VBELP type C length 6,
     VETEN type C length 4,
     BSTYP type C length 1,
     EKORG type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
     ZEKKN type C length 2,
  end of TS_VL_SH_MEKKV .
  types:
TT_VL_SH_MEKKV type standard table of TS_VL_SH_MEKKV .
  types:
  begin of TS_VL_SH_MEKKW,
     RESWK type C length 4,
     EKORG type C length 4,
     BSTYP type C length 1,
     EKGRP type C length 3,
     EBELN type C length 10,
  end of TS_VL_SH_MEKKW .
  types:
TT_VL_SH_MEKKW type standard table of TS_VL_SH_MEKKW .
  types:
  begin of TS_VL_SH_MEKK_TM,
     TSP_ID type C length 10,
     SRC_LOC_ID type C length 20,
     DEST_LOC_ID type C length 20,
     PICKUP_D type TIMESTAMP,
     DELV_D type TIMESTAMP,
     TOR_ID type C length 20,
     EBELN type C length 10,
  end of TS_VL_SH_MEKK_TM .
  types:
TT_VL_SH_MEKK_TM type standard table of TS_VL_SH_MEKK_TM .
  types:
  begin of TS_VL_SH_MEKK_TREX_ADVANCED,
     BUSINESS_OBJECT type C length 10,
     OBJECT_TYPE type C length 10,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
     EXTERNAL_KEY type C length 10,
     BSTYP type C length 1,
     BSART type C length 4,
     EKORG type C length 4,
     LIFNR type C length 10,
     BEDAT type TIMESTAMP,
     EKGRP type C length 3,
     WERKS type C length 4,
     MATNR type C length 40,
     MATKL type C length 9,
     TXZ01 type C length 40,
     KNTTP type C length 1,
  end of TS_VL_SH_MEKK_TREX_ADVANCED .
  types:
TT_VL_SH_MEKK_TREX_ADVANCED type standard table of TS_VL_SH_MEKK_TREX_ADVANCED .
  types:
  begin of TS_VL_SH_MEKK_TREX_SIMPLE,
     BEDAT type TIMESTAMP,
     BSART type C length 4,
     BSTYP type C length 1,
     BUSINESS_OBJECT type C length 10,
     EKGRP type C length 3,
     EKORG type C length 4,
     EXTERNAL_KEY type C length 10,
     KNTTP type C length 1,
     LIFNR type C length 10,
     MATKL type C length 9,
     MATNR type C length 40,
     OBJECT_TYPE type C length 10,
     TXZ01 type C length 40,
     WERKS type C length 4,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_MEKK_TREX_SIMPLE .
  types:
TT_VL_SH_MEKK_TREX_SIMPLE type standard table of TS_VL_SH_MEKK_TREX_SIMPLE .
  types:
  begin of TS_VL_SH_MMBSI_MEKK_DBSH_CC,
     AEDAT type TIMESTAMP,
     BSTYP type C length 1,
     BUKRS type C length 4,
     EBELN type C length 10,
     EBELP type C length 5,
     ZTERM type C length 4,
     HIERARCHY_EXISTS type FLAG,
     WAERS type C length 5,
     THRESHOLD_EXISTS type FLAG,
     KTMNG type P length 7 decimals 3,
     KTWRT type P length 8 decimals 2,
     STATU type C length 1,
     LOEKZ type C length 1,
     MEINS type C length 3,
     MMBSI_MENGE type P length 7 decimals 3,
     MMBSI_NETWR type P length 8 decimals 2,
     NETPR type P length 6 decimals 2,
     RELEASE_DATE type TIMESTAMP,
     SRM_CONTRACT_ID type C length 10,
     SRM_CONTRACT_ITM type C length 10,
     DESCRIPTION type C length 40,
     MATNR type C length 40,
     TXZ01 type C length 40,
     WERKS type C length 4,
     KDATB type TIMESTAMP,
     KDATE type TIMESTAMP,
     LIFNR type C length 10,
     EKORG type C length 4,
     PSTYP type C length 1,
  end of TS_VL_SH_MMBSI_MEKK_DBSH_CC .
  types:
TT_VL_SH_MMBSI_MEKK_DBSH_CC type standard table of TS_VL_SH_MMBSI_MEKK_DBSH_CC .
  types:
  begin of TS_VL_SH_MMBSI_MEKK_TREX_CC,
     ZTERM type C length 4,
     WERKS type C length 4,
     WAERS type C length 5,
     TXZ01 type C length 40,
     THRESHOLD_EXISTS type FLAG,
     STATU type C length 1,
     SRM_CONTRACT_ITM type C length 10,
     SRM_CONTRACT_ID type C length 10,
     S_RP_MODE_FUZZY type FLAG,
     REQUEST type C length 32,
     RELEASE_DATE type TIMESTAMP,
     PSTYP type C length 1,
     OBJECT_TYPE_ID type C length 20,
     NETPR type P length 6 decimals 2,
     MMBSI_NETWR type P length 8 decimals 2,
     MMBSI_MENGE type P length 7 decimals 3,
     MEINS type C length 3,
     MATNR type C length 40,
     LOEKZ type C length 1,
     LIFNR type C length 10,
     KTWRT type P length 8 decimals 2,
     KTMNG type P length 7 decimals 3,
     KDATE type TIMESTAMP,
     KDATB type TIMESTAMP,
     HIERACHY_EXISTS type FLAG,
     EKORG type C length 4,
     EBELP type C length 5,
     EBELN type C length 10,
     DESCRIPTION type C length 40,
     BUKRS type C length 4,
     BSTYP type C length 1,
     AEDAT type TIMESTAMP,
     S_RP_SEARCH_TERM type C length 45,
  end of TS_VL_SH_MMBSI_MEKK_TREX_CC .
  types:
TT_VL_SH_MMBSI_MEKK_TREX_CC type standard table of TS_VL_SH_MMBSI_MEKK_TREX_CC .
  types:
  begin of TS_VL_SH_MPNKRED1,
     BEGRU type C length 4,
     KTOKK type C length 4,
     EMNFR type C length 10,
     LIFNR type C length 10,
     NAME1 type C length 35,
  end of TS_VL_SH_MPNKRED1 .
  types:
TT_VL_SH_MPNKRED1 type standard table of TS_VL_SH_MPNKRED1 .
  types:
  begin of TS_VL_SH_ORDEA,
     KOKRS type C length 4,
     ABKRS type C length 2,
     AUART type C length 4,
     AUFNR type C length 12,
     KTEXT type C length 40,
  end of TS_VL_SH_ORDEA .
  types:
TT_VL_SH_ORDEA type standard table of TS_VL_SH_ORDEA .
  types:
  begin of TS_VL_SH_ORDEB,
     AUART type C length 4,
     KOKRS type C length 4,
     AUFNR type C length 12,
     KTEXT type C length 40,
  end of TS_VL_SH_ORDEB .
  types:
TT_VL_SH_ORDEB type standard table of TS_VL_SH_ORDEB .
  types:
  begin of TS_VL_SH_ORDEB_TYPEAHEAD,
     AUART type C length 4,
     KOKRS type C length 4,
     AUFNR type C length 12,
     KTEXT type C length 40,
  end of TS_VL_SH_ORDEB_TYPEAHEAD .
  types:
TT_VL_SH_ORDEB_TYPEAHEAD type standard table of TS_VL_SH_ORDEB_TYPEAHEAD .
  types:
  begin of TS_VL_SH_ORDEC,
     AUTYP type C length 2,
     PRODNET type C length 1,
     AUFNR type C length 12,
     KTEXT type C length 40,
     MAUFNR type C length 12,
  end of TS_VL_SH_ORDEC .
  types:
TT_VL_SH_ORDEC type standard table of TS_VL_SH_ORDEC .
  types:
  begin of TS_VL_SH_ORDED,
     DISPO type C length 3,
     WERKS type C length 4,
     AUFNR type C length 12,
     AUART type C length 4,
     GSTRS type TIMESTAMP,
     GLTRS type TIMESTAMP,
  end of TS_VL_SH_ORDED .
  types:
TT_VL_SH_ORDED type standard table of TS_VL_SH_ORDED .
  types:
  begin of TS_VL_SH_ORDEF,
     FEVOR type C length 3,
     WERKS type C length 4,
     AUFNR type C length 12,
     AUART type C length 4,
     GSTRS type TIMESTAMP,
     GLTRS type TIMESTAMP,
  end of TS_VL_SH_ORDEF .
  types:
TT_VL_SH_ORDEF type standard table of TS_VL_SH_ORDEF .
  types:
  begin of TS_VL_SH_ORDER_SES_ADVANCED,
     BUSINESS_OBJECT type C length 10,
     OBJECT_TYPE type C length 10,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
     EXTERNAL_KEY type C length 12,
     KOKRS type C length 4,
     AUART type C length 4,
     AUTYP type C length 2,
     DESCRIPTION type C length 40,
     BUKRS type C length 4,
     WERKS type C length 4,
     KOSTV type C length 10,
     PRCTR type C length 10,
     STAT type C length 5,
  end of TS_VL_SH_ORDER_SES_ADVANCED .
  types:
TT_VL_SH_ORDER_SES_ADVANCED type standard table of TS_VL_SH_ORDER_SES_ADVANCED .
  types:
  begin of TS_VL_SH_ORDER_SES_QUICK,
     AUART type C length 4,
     AUTYP type C length 2,
     BUKRS type C length 4,
     BUSINESS_OBJECT type C length 10,
     DESCRIPTION type C length 40,
     EXTERNAL_KEY type C length 12,
     KOKRS type C length 4,
     KOSTV type C length 10,
     OBJECT_TYPE type C length 10,
     PRCTR type C length 10,
     STAT type C length 5,
     WERKS type C length 4,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_ORDER_SES_QUICK .
  types:
TT_VL_SH_ORDER_SES_QUICK type standard table of TS_VL_SH_ORDER_SES_QUICK .
  types:
  begin of TS_VL_SH_ORDES,
     AUTYP type C length 2,
     PRODNET type C length 1,
     AUFNR type C length 12,
     KTEXT type C length 40,
     MAUFNR type C length 12,
  end of TS_VL_SH_ORDES .
  types:
TT_VL_SH_ORDES type standard table of TS_VL_SH_ORDES .
  types:
  begin of TS_VL_SH_ORDET,
     DISPO type C length 3,
     WERKS type C length 4,
     AUFNR type C length 12,
     AUART type C length 4,
     GSTRS type TIMESTAMP,
     GLTRS type TIMESTAMP,
  end of TS_VL_SH_ORDET .
  types:
TT_VL_SH_ORDET type standard table of TS_VL_SH_ORDET .
  types:
  begin of TS_VL_SH_ORDEU,
     FEVOR type C length 3,
     WERKS type C length 4,
     AUFNR type C length 12,
     AUART type C length 4,
     GSTRS type TIMESTAMP,
     GLTRS type TIMESTAMP,
  end of TS_VL_SH_ORDEU .
  types:
TT_VL_SH_ORDEU type standard table of TS_VL_SH_ORDEU .
  types:
  begin of TS_VL_SH_REBDBENOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     XWETEXT type C length 60,
     RESPONSIBLE type C length 12,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBENOA .
  types:
TT_VL_SH_REBDBENOA type standard table of TS_VL_SH_REBDBENOA .
  types:
  begin of TS_VL_SH_REBDBENOE,
     CITY1 type C length 40,
     IMKEY type C length 40,
     OBJNR type C length 22,
     STREET type C length 60,
     BUKRS type C length 4,
     SWENR type C length 8,
     COUNTRY type C length 3,
     REGION type C length 3,
     POST_CODE1 type C length 10,
     MC_CITY1 type C length 25,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     ADRZUS type C length 35,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBENOE .
  types:
TT_VL_SH_REBDBENOE type standard table of TS_VL_SH_REBDBENOE .
  types:
  begin of TS_VL_SH_REBDBENOF,
     CITY1 type C length 40,
     IMKEY type C length 40,
     OBJNR type C length 22,
     STREET type C length 60,
     BUKRS type C length 4,
     SWENR type C length 8,
     COUNTRY type C length 3,
     REGION type C length 3,
     POST_CODE1 type C length 10,
     MC_CITY1 type C length 25,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     ADRZUS type C length 35,
  end of TS_VL_SH_REBDBENOF .
  types:
TT_VL_SH_REBDBENOF type standard table of TS_VL_SH_REBDBENOF .
  types:
  begin of TS_VL_SH_REBDBENOO,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     XWETEXT type C length 60,
     AUFNR type C length 12,
     AUART type C length 4,
     KTEXT type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBENOO .
  types:
TT_VL_SH_REBDBENOO type standard table of TS_VL_SH_REBDBENOO .
  types:
  begin of TS_VL_SH_REBDBENOOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     OBJNRTRG type C length 22,
     OBJTYPESRC type C length 2,
     IDENTTRG type C length 50,
     BUKRS type C length 4,
     SWENR type C length 8,
     XWETEXT type C length 60,
     RESPONSIBLE type C length 12,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBENOOA .
  types:
TT_VL_SH_REBDBENOOA type standard table of TS_VL_SH_REBDBENOOA .
  types:
  begin of TS_VL_SH_REBDBENOP,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     XWETEXT type C length 60,
     TPLNR type C length 40,
     SPRAS type C length 2,
     PLTXT type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBENOP .
  types:
TT_VL_SH_REBDBENOP type standard table of TS_VL_SH_REBDBENOP .
  types:
  begin of TS_VL_SH_REBDBENOSE1,
     AD_CITY1 type C length 40,
     AD_STREET type C length 60,
     BUKRS type C length 4,
     BUSINESS_OBJECT type C length 10,
     EXTERNAL_KEY type C length 8,
     NEIGHBORH type C length 30,
     OBJECT_ID type C length 22,
     OBJECT_TYPE type C length 10,
     XWETEXT type C length 60,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_REBDBENOSE1 .
  types:
TT_VL_SH_REBDBENOSE1 type standard table of TS_VL_SH_REBDBENOSE1 .
  types:
  begin of TS_VL_SH_REBDBENOSE2,
     AD_CITY1 type C length 40,
     AD_STREET type C length 60,
     BUSINESS_OBJECT type C length 10,
     EXTERNAL_KEY type C length 8,
     NEIGHBORH type C length 30,
     OBJECT_ID type C length 22,
     OBJECT_TYPE type C length 10,
     XWETEXT type C length 60,
     S_RP_SEARCH_TERM type C length 45,
     BUKRS type C length 4,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_REBDBENOSE2 .
  types:
TT_VL_SH_REBDBENOSE2 type standard table of TS_VL_SH_REBDBENOSE2 .
  types:
  begin of TS_VL_SH_REBDBUNOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     XGETXT type C length 60,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBUNOA .
  types:
TT_VL_SH_REBDBUNOA type standard table of TS_VL_SH_REBDBUNOA .
  types:
  begin of TS_VL_SH_REBDBUNOE,
     CITY1 type C length 40,
     OBJNR type C length 22,
     STREET type C length 60,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     COUNTRY type C length 3,
     REGION type C length 3,
     POST_CODE1 type C length 10,
     MC_CITY1 type C length 25,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     ADRZUS type C length 35,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBUNOE .
  types:
TT_VL_SH_REBDBUNOE type standard table of TS_VL_SH_REBDBUNOE .
  types:
  begin of TS_VL_SH_REBDBUNOG,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     XGETXT type C length 60,
     GEMEINDE type C length 8,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBUNOG .
  types:
TT_VL_SH_REBDBUNOG type standard table of TS_VL_SH_REBDBUNOG .
  types:
  begin of TS_VL_SH_REBDBUNOO,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     XGETXT type C length 60,
     AUFNR type C length 12,
     AUART type C length 4,
     KTEXT type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBUNOO .
  types:
TT_VL_SH_REBDBUNOO type standard table of TS_VL_SH_REBDBUNOO .
  types:
  begin of TS_VL_SH_REBDBUNOOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     OBJNRTRG type C length 22,
     OBJTYPESRC type C length 2,
     IDENTTRG type C length 50,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     XGETXT type C length 60,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBUNOOA .
  types:
TT_VL_SH_REBDBUNOOA type standard table of TS_VL_SH_REBDBUNOOA .
  types:
  begin of TS_VL_SH_REBDBUNOP,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     TPLNR type C length 40,
     SPRAS type C length 2,
     PLTXT type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDBUNOP .
  types:
TT_VL_SH_REBDBUNOP type standard table of TS_VL_SH_REBDBUNOP .
  types:
  begin of TS_VL_SH_REBDPRNOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     XGRTXT type C length 60,
     SUNUTZA type C length 8,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDPRNOA .
  types:
TT_VL_SH_REBDPRNOA type standard table of TS_VL_SH_REBDPRNOA .
  types:
  begin of TS_VL_SH_REBDPRNOE,
     CITY1 type C length 40,
     OBJNR type C length 22,
     STREET type C length 60,
     POST_CODE1 type C length 10,
     MC_CITY1 type C length 25,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     ADRZUS type C length 35,
     COUNTRY type C length 3,
     REGION type C length 3,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDPRNOE .
  types:
TT_VL_SH_REBDPRNOE type standard table of TS_VL_SH_REBDPRNOE .
  types:
  begin of TS_VL_SH_REBDPRNOG,
     OBJNR type C length 22,
     GEMEINDE type C length 8,
     XGEMARK type C length 12,
     NFLURNR type C length 6,
     XFLURST type C length 10,
     BRFLURST type C length 4,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     XGRTXT type C length 60,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDPRNOG .
  types:
TT_VL_SH_REBDPRNOG type standard table of TS_VL_SH_REBDPRNOG .
  types:
  begin of TS_VL_SH_REBDPRNOO,
     OBJNR type C length 22,
     AUFNR type C length 12,
     AUART type C length 4,
     KTEXT type C length 40,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     XGRTXT type C length 60,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDPRNOO .
  types:
TT_VL_SH_REBDPRNOO type standard table of TS_VL_SH_REBDPRNOO .
  types:
  begin of TS_VL_SH_REBDPRNOOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     OBJNRTRG type C length 22,
     OBJTYPESRC type C length 2,
     IDENTTRG type C length 50,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     XGRTXT type C length 60,
     SUNUTZA type C length 8,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDPRNOOA .
  types:
TT_VL_SH_REBDPRNOOA type standard table of TS_VL_SH_REBDPRNOOA .
  types:
  begin of TS_VL_SH_REBDPRNOP,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     XGRTXT type C length 60,
     TPLNR type C length 40,
     SPRAS type C length 2,
     PLTXT type C length 40,
     USGFUNCTION type C length 4,
  end of TS_VL_SH_REBDPRNOP .
  types:
TT_VL_SH_REBDPRNOP type standard table of TS_VL_SH_REBDPRNOP .
  types:
  begin of TS_VL_SH_REBDRONOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     XMETXT type C length 60,
     BUKRS type C length 4,
     SWENR type C length 8,
     SMENR type C length 8,
     ROTYPE type C length 2,
     SNUNR type C length 4,
     SGENR type C length 8,
     SGRNR type C length 8,
     DBEZU type TIMESTAMP,
     XSTOCKK type C length 4,
     RLGESCH type C length 2,
     SALTNR type C length 20,
     RESPONSIBLE type C length 12,
  end of TS_VL_SH_REBDRONOA .
  types:
TT_VL_SH_REBDRONOA type standard table of TS_VL_SH_REBDRONOA .
  types:
  begin of TS_VL_SH_REBDRONOB,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     XGETXT type C length 60,
     ROTYPE type C length 2,
     SMENR type C length 8,
     XMETXT type C length 60,
  end of TS_VL_SH_REBDRONOB .
  types:
TT_VL_SH_REBDRONOB type standard table of TS_VL_SH_REBDRONOB .
  types:
  begin of TS_VL_SH_REBDRONOC,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     XGRTXT type C length 60,
     ROTYPE type C length 2,
     SMENR type C length 8,
     XMETXT type C length 60,
  end of TS_VL_SH_REBDRONOC .
  types:
TT_VL_SH_REBDRONOC type standard table of TS_VL_SH_REBDRONOC .
  types:
  begin of TS_VL_SH_REBDRONOD,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     XWETEXT type C length 60,
     ROTYPE type C length 2,
     SMENR type C length 8,
     XMETXT type C length 60,
  end of TS_VL_SH_REBDRONOD .
  types:
TT_VL_SH_REBDRONOD type standard table of TS_VL_SH_REBDRONOD .
  types:
  begin of TS_VL_SH_REBDRONOE,
     CITY1 type C length 40,
     IMKEY type C length 40,
     OBJNR type C length 22,
     STREET type C length 60,
     XMETXT type C length 60,
     BUKRS type C length 4,
     SWENR type C length 8,
     ROTYPE type C length 2,
     SMENR type C length 8,
     COUNTRY type C length 3,
     REGION type C length 3,
     POST_CODE1 type C length 10,
     MC_CITY1 type C length 25,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     ADRZUS type C length 35,
  end of TS_VL_SH_REBDRONOE .
  types:
TT_VL_SH_REBDRONOE type standard table of TS_VL_SH_REBDRONOE .
  types:
  begin of TS_VL_SH_REBDRONOG,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     SMENR type C length 8,
     ROTYPE type C length 2,
     XMETXT type C length 60,
     GEMEINDE type C length 8,
  end of TS_VL_SH_REBDRONOG .
  types:
TT_VL_SH_REBDRONOG type standard table of TS_VL_SH_REBDRONOG .
  types:
  begin of TS_VL_SH_REBDRONOH,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     SMENR type C length 8,
     ROTYPE type C length 2,
     XMETXT type C length 60,
     GEMEINDE type C length 8,
  end of TS_VL_SH_REBDRONOH .
  types:
TT_VL_SH_REBDRONOH type standard table of TS_VL_SH_REBDRONOH .
  types:
  begin of TS_VL_SH_REBDRONOMS,
     IMKEY type C length 40,
     MEASUNIT type C length 3,
     OBJNR type C length 22,
     SPRAS type C length 2,
     XMMEAS type C length 30,
     BUKRS type C length 4,
     SWENR type C length 8,
     ROTYPE type C length 2,
     SNUNR type C length 4,
     SMENR type C length 8,
     XMETXT type C length 60,
     MEAS type C length 4,
     MEASVALUECMPL type P length 9 decimals 4,
     VALIDFROM type TIMESTAMP,
     VALIDTO type TIMESTAMP,
  end of TS_VL_SH_REBDRONOMS .
  types:
TT_VL_SH_REBDRONOMS type standard table of TS_VL_SH_REBDRONOMS .
  types:
  begin of TS_VL_SH_REBDRONOO,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     ROTYPE type C length 2,
     SMENR type C length 8,
     XMETXT type C length 60,
     AUFNR type C length 12,
     AUART type C length 4,
     KTEXT type C length 40,
  end of TS_VL_SH_REBDRONOO .
  types:
TT_VL_SH_REBDRONOO type standard table of TS_VL_SH_REBDRONOO .
  types:
  begin of TS_VL_SH_REBDRONOOA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     OBJNRTRG type C length 22,
     OBJTYPESRC type C length 2,
     XMETXT type C length 60,
     IDENTTRG type C length 50,
     BUKRS type C length 4,
     SWENR type C length 8,
     SMENR type C length 8,
     ROTYPE type C length 2,
     SNUNR type C length 4,
     SGENR type C length 8,
     SGRNR type C length 8,
     DBEZU type TIMESTAMP,
     XSTOCKK type C length 4,
     RLGESCH type C length 2,
     SALTNR type C length 20,
     RESPONSIBLE type C length 12,
  end of TS_VL_SH_REBDRONOOA .
  types:
TT_VL_SH_REBDRONOOA type standard table of TS_VL_SH_REBDRONOOA .
  types:
  begin of TS_VL_SH_REBDRONOOC,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SMENR type C length 8,
     ROTYPE type C length 2,
     USAGETYPE type C length 4,
     OCCFROM type TIMESTAMP,
     OCCTO type TIMESTAMP,
     XMETXT type C length 60,
  end of TS_VL_SH_REBDRONOOC .
  types:
TT_VL_SH_REBDRONOOC type standard table of TS_VL_SH_REBDRONOOC .
  types:
  begin of TS_VL_SH_REBDRONOOO,
     OBJNR type C length 22,
     BUKRS type C length 4,
     BENO type C length 8,
     RONO type C length 8,
     BUNO type C length 8,
     PRNO type C length 8,
     OOID type C length 20,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
     OOBEG type TIMESTAMP,
     OOEND type TIMESTAMP,
     ROTYPE type C length 2,
     SNUNR type C length 4,
     XOO type C length 255,
     CDVALUE01 type P length 8 decimals 2,
     CDVALUE02 type P length 8 decimals 2,
     MSVALUE01 type P length 9 decimals 4,
     MSVALUE02 type P length 9 decimals 4,
     FLOOR type C length 2,
     SSTDORT type C length 10,
     SLAGEWE type C length 4,
     SOBJLAGE type C length 2,
     TRANSPCONN type C length 1,
     BUILDYEAR type TIMESTAMP,
     REGION type C length 3,
     POST_CODE1 type C length 10,
     CITY1 type C length 40,
     CITY2 type C length 40,
     STREET type C length 60,
     HOUSE_NUM1 type C length 10,
  end of TS_VL_SH_REBDRONOOO .
  types:
TT_VL_SH_REBDRONOOO type standard table of TS_VL_SH_REBDRONOOO .
  types:
  begin of TS_VL_SH_REBDRONOP,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     ROTYPE type C length 2,
     SMENR type C length 8,
     XMETXT type C length 60,
     TPLNR type C length 40,
     SPRAS type C length 2,
     PLTXT type C length 40,
  end of TS_VL_SH_REBDRONOP .
  types:
TT_VL_SH_REBDRONOP type standard table of TS_VL_SH_REBDRONOP .
  types:
  begin of TS_VL_SH_REBDRONOT,
     IMKEY type C length 40,
     OBJNR type C length 22,
     XMETXT type C length 60,
     PG_BUKRS type C length 4,
     PG_SWENR type C length 8,
     PGID type C length 10,
     XPG type C length 60,
     BUKRS type C length 4,
     SWENR type C length 8,
     ROTYPE type C length 2,
     SMENR type C length 8,
  end of TS_VL_SH_REBDRONOT .
  types:
TT_VL_SH_REBDRONOT type standard table of TS_VL_SH_REBDRONOT .
  types:
  begin of TS_VL_SH_RECNCNA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     BENOCN type C length 8,
     RECNTXT type C length 80,
     INDUSTRY type C length 10,
     SRRELEVANT type FLAG,
     RECNNOTPER type TIMESTAMP,
     RECNNOTREASON type C length 2,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
     RECNBUKRSCOLLECT type C length 4,
     RECNNRCOLLECT type C length 13,
     RECNTXTOLD type C length 20,
  end of TS_VL_SH_RECNCNA .
  types:
TT_VL_SH_RECNCNA type standard table of TS_VL_SH_RECNCNA .
  types:
  begin of TS_VL_SH_RECNCNB,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     BENOCN type C length 8,
     RECNTXT type C length 80,
     INDUSTRY type C length 10,
     SRRELEVANT type FLAG,
     RECNNOTPER type TIMESTAMP,
     RECNNOTREASON type C length 2,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
     RECNBUKRSCOLLECT type C length 4,
     RECNNRCOLLECT type C length 13,
     RECNTXTOLD type C length 20,
  end of TS_VL_SH_RECNCNB .
  types:
TT_VL_SH_RECNCNB type standard table of TS_VL_SH_RECNCNB .
  types:
  begin of TS_VL_SH_RECNCND,
     IMKEY type C length 40,
     NAME_FIRST type C length 40,
     NAME_GRP1 type C length 40,
     NAME_LAST type C length 40,
     NAME_ORG1 type C length 40,
     OBJNR type C length 22,
     XROLE type C length 50,
     BUKRS type C length 4,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     BENOCN type C length 8,
     PARTNER type C length 10,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     MC_CITY1 type C length 25,
     POST_CODE1 type C length 10,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     COUNTRY type C length 3,
     ROLE type C length 6,
     SPRAS type C length 2,
  end of TS_VL_SH_RECNCND .
  types:
TT_VL_SH_RECNCND type standard table of TS_VL_SH_RECNCND .
  types:
  begin of TS_VL_SH_RECNCNE,
     IMKEY type C length 40,
     OBJNR type C length 22,
     VALIDFROM type TIMESTAMP,
     VALIDTO type TIMESTAMP,
     BUKRS type C length 4,
     BUKRSRO type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     SGENR type C length 8,
     SMENR type C length 8,
     ROTYPE type C length 2,
     SNUNR type C length 4,
     XMETXT type C length 60,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     RECNTXT type C length 80,
  end of TS_VL_SH_RECNCNE .
  types:
TT_VL_SH_RECNCNE type standard table of TS_VL_SH_RECNCNE .
  types:
  begin of TS_VL_SH_RECNCNF,
     IMKEY type C length 40,
     OBJNR type C length 22,
     VALIDFROM type TIMESTAMP,
     VALIDTO type TIMESTAMP,
     BUKRS type C length 4,
     BUKRSBE type C length 4,
     SWENR type C length 8,
     XWETEXT type C length 60,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     RECNTXT type C length 80,
  end of TS_VL_SH_RECNCNF .
  types:
TT_VL_SH_RECNCNF type standard table of TS_VL_SH_RECNCNF .
  types:
  begin of TS_VL_SH_RECNCNG,
     IMKEY type C length 40,
     OBJNR type C length 22,
     VALIDFROM type TIMESTAMP,
     VALIDTO type TIMESTAMP,
     BUKRS type C length 4,
     BUKRSPR type C length 4,
     SWENR type C length 8,
     SGRNR type C length 8,
     XGRTXT type C length 60,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     RECNTXT type C length 80,
  end of TS_VL_SH_RECNCNG .
  types:
TT_VL_SH_RECNCNG type standard table of TS_VL_SH_RECNCNG .
  types:
  begin of TS_VL_SH_RECNCNH,
     IMKEY type C length 40,
     OBJNR type C length 22,
     VALIDFROM type TIMESTAMP,
     VALIDTO type TIMESTAMP,
     BUKRS type C length 4,
     BUKRSBU type C length 4,
     SWENR type C length 8,
     SGENR type C length 8,
     XGETXT type C length 60,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     RECNTXT type C length 80,
  end of TS_VL_SH_RECNCNH .
  types:
TT_VL_SH_RECNCNH type standard table of TS_VL_SH_RECNCNH .
  types:
  begin of TS_VL_SH_RECNCNINV,
     CUSTOMER type C length 10,
     NAME1 type C length 35,
     OBJNR type C length 22,
     ORT01 type C length 35,
     PARTNER type C length 10,
     RECNNR type C length 13,
     INVNO type C length 10,
     FISC_YEAR type C length 4,
     BUKRS type C length 4,
  end of TS_VL_SH_RECNCNINV .
  types:
TT_VL_SH_RECNCNINV type standard table of TS_VL_SH_RECNCNINV .
  types:
  begin of TS_VL_SH_RECNCNK,
     IMKEY type C length 40,
     OBJNR type C length 22,
     TERMNO type C length 4,
     VALIDFROM type TIMESTAMP,
     VALIDTO type TIMESTAMP,
     ADJMRULE type C length 10,
     BUKRS type C length 4,
     RECNTYPE type C length 4,
     RECNNR type C length 13,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     BENOCN type C length 8,
     RECNTXT type C length 80,
     RESPONSIBLE type C length 12,
     AUTHGRP type C length 40,
  end of TS_VL_SH_RECNCNK .
  types:
TT_VL_SH_RECNCNK type standard table of TS_VL_SH_RECNCNK .
  types:
  begin of TS_VL_SH_RECNCNSE1,
     BUKRS type C length 4,
     BUSINESS_OBJECT type C length 10,
     CITY1 type C length 40,
     EXTERNAL_KEY type C length 13,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     OBJECT_ID type C length 22,
     OBJECT_TYPE type C length 10,
     RECNTXT type C length 80,
     RLTXT type C length 50,
     STREET type C length 60,
     XINDUSTRY type C length 20,
     S_RP_SEARCH_TERM type C length 45,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_RECNCNSE1 .
  types:
TT_VL_SH_RECNCNSE1 type standard table of TS_VL_SH_RECNCNSE1 .
  types:
  begin of TS_VL_SH_RECNCNSE2,
     BUSINESS_OBJECT type C length 10,
     CITY1 type C length 40,
     EXTERNAL_KEY type C length 13,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     OBJECT_ID type C length 22,
     OBJECT_TYPE type C length 10,
     RECNTXT type C length 80,
     RLTXT type C length 50,
     STREET type C length 60,
     XINDUSTRY type C length 20,
     S_RP_SEARCH_TERM type C length 45,
     BUKRS type C length 4,
     BENOCN type C length 8,
     S_RP_MODE_FUZZY type C length 1,
  end of TS_VL_SH_RECNCNSE2 .
  types:
TT_VL_SH_RECNCNSE2 type standard table of TS_VL_SH_RECNCNSE2 .
  types:
  begin of TS_VL_SH_REKUNNRCN,
     BEGRU type C length 4,
     KTOKD type C length 4,
     KUNNR type C length 10,
     NAME_FIRST type C length 40,
     NAME_LAST type C length 40,
     NAME_ORG1 type C length 40,
     NAME_ORG2 type C length 40,
     ROLE type C length 6,
     RECNNR type C length 13,
     BUKRS type C length 4,
     RECNTYPE type C length 4,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     RECNNOTPER type TIMESTAMP,
     RECNTXTOLD type C length 20,
     RECNNRCOLLECT type C length 13,
     RECNTXT type C length 80,
  end of TS_VL_SH_REKUNNRCN .
  types:
TT_VL_SH_REKUNNRCN type standard table of TS_VL_SH_REKUNNRCN .
  types:
  begin of TS_VL_SH_REKUNNR_VIRAINV,
     BEGRU type C length 4,
     CUSTOMER type C length 10,
     KTOKD type C length 4,
     NAME1 type C length 35,
     NAME2 type C length 35,
     ORT01 type C length 35,
     PARTNER type C length 10,
     PSTLZ type C length 10,
     INVNO type C length 10,
     FISC_YEAR type C length 4,
     BUKRS type C length 4,
  end of TS_VL_SH_REKUNNR_VIRAINV .
  types:
TT_VL_SH_REKUNNR_VIRAINV type standard table of TS_VL_SH_REKUNNR_VIRAINV .
  types:
  begin of TS_VL_SH_RELIFNRCN,
     BEGRU type C length 4,
     KTOKK type C length 4,
     LIFNR type C length 10,
     NAME_FIRST type C length 40,
     NAME_LAST type C length 40,
     NAME_ORG1 type C length 40,
     NAME_ORG2 type C length 40,
     RECNNR type C length 13,
     BUKRS type C length 4,
     RECNTYPE type C length 4,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     RECNBEG type TIMESTAMP,
     RECNENDABS type TIMESTAMP,
     RECNNOTPER type TIMESTAMP,
     RECNTXTOLD type C length 20,
     RECNNRCOLLECT type C length 13,
     RECNTXT type C length 80,
  end of TS_VL_SH_RELIFNRCN .
  types:
TT_VL_SH_RELIFNRCN type standard table of TS_VL_SH_RELIFNRCN .
  types:
  begin of TS_VL_SH_RESCSCKEYA,
     CUEXCLUDEASSIGN type FLAG,
     SPRAS type C length 2,
     SNKSL type C length 4,
     XSCKEY type C length 30,
     DIRECTCOSTID type C length 1,
  end of TS_VL_SH_RESCSCKEYA .
  types:
TT_VL_SH_RESCSCKEYA type standard table of TS_VL_SH_RESCSCKEYA .
  types:
  begin of TS_VL_SH_RESCSCKEYB,
     CUEXCLUDEASSIGN type FLAG,
     SPRAS type C length 2,
     XSCKEY type C length 30,
     XSCKEYGRP type C length 30,
     SCKEYGRP type C length 4,
     SNKSL type C length 4,
  end of TS_VL_SH_RESCSCKEYB .
  types:
TT_VL_SH_RESCSCKEYB type standard table of TS_VL_SH_RESCSCKEYB .
  types:
  begin of TS_VL_SH_RESCSUA,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SNKSL type C length 4,
     SEMPSL type C length 5,
     XTEXTAE type C length 60,
     SUTYPE type C length 2,
     RESPONSIBLE type C length 12,
  end of TS_VL_SH_RESCSUA .
  types:
TT_VL_SH_RESCSUA type standard table of TS_VL_SH_RESCSUA .
  types:
  begin of TS_VL_SH_RESCSUB,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SNKSL type C length 4,
     SEMPSL type C length 5,
     XSU type C length 60,
     RESPONSIBLE type C length 12,
     SKABRF type C length 3,
     XMBEZ type C length 30,
     ABRKDNR type C length 7,
     INTERNAL_OBJID type C length 20,
     EXTERNAL_OBJID type C length 13,
  end of TS_VL_SH_RESCSUB .
  types:
TT_VL_SH_RESCSUB type standard table of TS_VL_SH_RESCSUB .
  types:
  begin of TS_VL_SH_RESCSUC,
     BUKRS type C length 4,
     IMKEY type C length 40,
     OBJNR type C length 22,
     RESPONSIBLE type C length 12,
     SEMPSL type C length 5,
     SWENR type C length 8,
     XSU type C length 60,
     PG_BUKRS type C length 4,
     PG_SWENR type C length 8,
     PG_PGID type C length 10,
     PG_XPG type C length 60,
     PG_RESPONSIBLE type C length 12,
     SNKSL type C length 4,
  end of TS_VL_SH_RESCSUC .
  types:
TT_VL_SH_RESCSUC type standard table of TS_VL_SH_RESCSUC .
  types:
  begin of TS_VL_SH_RESCSUG,
     IMKEY type C length 40,
     OBJNR type C length 22,
     BUKRS type C length 4,
     SWENR type C length 8,
     SCKEYGRP type C length 4,
     SNKSL type C length 4,
     SEMPSL type C length 5,
     XTEXTAE type C length 60,
     SUTYPE type C length 2,
  end of TS_VL_SH_RESCSUG .
  types:
TT_VL_SH_RESCSUG type standard table of TS_VL_SH_RESCSUG .
  types:
  begin of TS_VL_SH_SECCODE,
     NAME type C length 30,
     BUKRS type C length 4,
     SECCODE type C length 4,
     BPLACE type C length 4,
  end of TS_VL_SH_SECCODE .
  types:
TT_VL_SH_SECCODE type standard table of TS_VL_SH_SECCODE .
  types:
  begin of TS_VL_SH_SGT_MATNR_S,
     MATNR type C length 40,
     MAKTG type C length 40,
     SGT_CSGR type C length 4,
     SGT_COVSA type C length 8,
  end of TS_VL_SH_SGT_MATNR_S .
  types:
TT_VL_SH_SGT_MATNR_S type standard table of TS_VL_SH_SGT_MATNR_S .
  types:
  begin of TS_VL_SH_SH_FMAREA_CDS,
     FINANCIALMANAGEMENTAREA type C length 4,
     FINANCIALMANAGEMENTAREANAME type C length 25,
     FINANCIALMANAGEMENTAREACRCY type C length 5,
     FINMGMTAREAFISCALYEARVARIANT type C length 2,
  end of TS_VL_SH_SH_FMAREA_CDS .
  types:
TT_VL_SH_SH_FMAREA_CDS type standard table of TS_VL_SH_SH_FMAREA_CDS .
  types:
  begin of TS_VL_SH_SH_FMBPD_CDS,
     VALIDITYENDDATE type TIMESTAMP,
     VALIDITYSTARTDATE type TIMESTAMP,
     BUDGETPERIOD type C length 10,
     BUDGETPERIODNAME type C length 35,
     BUDGETPERIODAUTHZNGRP type C length 10,
     BUDGETPERIODEXPIRATIONDATE type TIMESTAMP,
     BUDGETPERIODPERIODICITY type C length 10,
  end of TS_VL_SH_SH_FMBPD_CDS .
  types:
TT_VL_SH_SH_FMBPD_CDS type standard table of TS_VL_SH_SH_FMBPD_CDS .
  types:
  begin of TS_VL_SH_SH_FMCI_CDS,
     FINANCIALMANAGEMENTAREA type C length 4,
     FINMGMTAREAFISCALYEAR type C length 4,
     COMMITMENTITEM type C length 24,
     COMMITMENTITEMNAME type C length 20,
     VALIDITYENDDATE type TIMESTAMP,
     VALIDITYSTARTDATE type TIMESTAMP,
  end of TS_VL_SH_SH_FMCI_CDS .
  types:
TT_VL_SH_SH_FMCI_CDS type standard table of TS_VL_SH_SH_FMCI_CDS .
  types:
  begin of TS_VL_SH_SH_FMFCTR_CDS,
     FINANCIALMANAGEMENTAREA type C length 4,
     FUNDSCENTER type C length 16,
     FUNDSCENTERNAME type C length 20,
     VALIDITYENDDATE type TIMESTAMP,
  end of TS_VL_SH_SH_FMFCTR_CDS .
  types:
TT_VL_SH_SH_FMFCTR_CDS type standard table of TS_VL_SH_SH_FMFCTR_CDS .
  types:
  begin of TS_VL_SH_SH_FMFUNDEDPRG_CDS,
     FINANCIALMANAGEMENTAREA type C length 4,
     FUNDEDPROGRAM type C length 24,
     VALIDITYENDDATE type TIMESTAMP,
     VALIDITYSTARTDATE type TIMESTAMP,
  end of TS_VL_SH_SH_FMFUNDEDPRG_CDS .
  types:
TT_VL_SH_SH_FMFUNDEDPRG_CDS type standard table of TS_VL_SH_SH_FMFUNDEDPRG_CDS .
  types:
  begin of TS_VL_SH_SH_FMFUNDSMGMTFUNCARE,
     FUNCTIONALAREA type C length 16,
     FUNCTIONALAREANAME type C length 25,
     VALIDITYSTARTDATE type TIMESTAMP,
     VALIDITYENDDATE type TIMESTAMP,
  end of TS_VL_SH_SH_FMFUNDSMGMTFUNCARE .
  types:
TT_VL_SH_SH_FMFUNDSMGMTFUNCARE type standard table of TS_VL_SH_SH_FMFUNDSMGMTFUNCARE .
  types:
  begin of TS_VL_SH_SH_FMFUND_CDS,
     FINANCIALMANAGEMENTAREA type C length 4,
     FUND type C length 10,
     FUNDNAME type C length 20,
     FUNDDESCRIPTION type C length 40,
     VALIDITYENDDATE type TIMESTAMP,
     VALIDITYSTARTDATE type TIMESTAMP,
     FUNDAUTHZNGRP type C length 10,
  end of TS_VL_SH_SH_FMFUND_CDS .
  types:
TT_VL_SH_SH_FMFUND_CDS type standard table of TS_VL_SH_SH_FMFUND_CDS .
  types:
  begin of TS_VL_SH_SH_GMGR_S4C_CDS,
     GRANTID type C length 20,
     GRANTNAME type C length 20,
     VALIDITYSTARTDATE type TIMESTAMP,
     VALIDITYENDDATE type TIMESTAMP,
  end of TS_VL_SH_SH_GMGR_S4C_CDS .
  types:
TT_VL_SH_SH_GMGR_S4C_CDS type standard table of TS_VL_SH_SH_GMGR_S4C_CDS .
  types:
  begin of TS_VL_SH_SH_PABKS,
     LAND1 type C length 3,
     LANDX type C length 15,
  end of TS_VL_SH_SH_PABKS .
  types:
TT_VL_SH_SH_PABKS type standard table of TS_VL_SH_SH_PABKS .
  types:
  begin of TS_VL_SH_SH_REPRO_REASON_CODE,
     REPROCREASONCODE type C length 2,
     RRC_TEXT type C length 60,
  end of TS_VL_SH_SH_REPRO_REASON_CODE .
  types:
TT_VL_SH_SH_REPRO_REASON_CODE type standard table of TS_VL_SH_SH_REPRO_REASON_CODE .
  types:
  begin of TS_VL_SH_SH_T007A,
     KALSM type C length 6,
     MWSKZ type C length 2,
     TEXT1 type C length 50,
  end of TS_VL_SH_SH_T007A .
  types:
TT_VL_SH_SH_T007A type standard table of TS_VL_SH_SH_T007A .
  types:
  begin of TS_VL_SH_SH_T028D,
     VGINT type C length 4,
     TXT20 type C length 40,
  end of TS_VL_SH_SH_T028D .
  types:
TT_VL_SH_SH_T028D type standard table of TS_VL_SH_SH_T028D .
  types:
  begin of TS_VL_SH_SH_TCURC,
     WAERS type C length 5,
     LTEXT type C length 40,
  end of TS_VL_SH_SH_TCURC .
  types:
TT_VL_SH_SH_TCURC type standard table of TS_VL_SH_SH_TCURC .
  types:
  begin of TS_VL_SH_VLCBUPAA,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     MC_CITY1 type C length 25,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     PARTNER type C length 10,
     RLTYP type C length 6,
  end of TS_VL_SH_VLCBUPAA .
  types:
TT_VL_SH_VLCBUPAA type standard table of TS_VL_SH_VLCBUPAA .
  types:
  begin of TS_VL_SH_VLCBUPAB,
     BANKL type C length 15,
     BANKN type C length 18,
     BANKS type C length 3,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     PARTNER type C length 10,
     RLTYP type C length 6,
  end of TS_VL_SH_VLCBUPAB .
  types:
TT_VL_SH_VLCBUPAB type standard table of TS_VL_SH_VLCBUPAB .
  types:
  begin of TS_VL_SH_VLCBUPAP,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     PARTNER type C length 10,
  end of TS_VL_SH_VLCBUPAP .
  types:
TT_VL_SH_VLCBUPAP type standard table of TS_VL_SH_VLCBUPAP .
  types:
  begin of TS_VL_SH_VLCBUPAS,
     AUGRP type C length 4,
     BU_SORT1 type C length 20,
     BU_SORT2 type C length 20,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     PARTNER type C length 10,
     RLTYP type C length 6,
  end of TS_VL_SH_VLCBUPAS .
  types:
TT_VL_SH_VLCBUPAS type standard table of TS_VL_SH_VLCBUPAS .
  types:
  begin of TS_VL_SH_WBWGA,
     MATKL type C length 9,
     WGBEZ type C length 20,
     WGBEZ60 type C length 60,
     SPRAS type C length 2,
  end of TS_VL_SH_WBWGA .
  types:
TT_VL_SH_WBWGA type standard table of TS_VL_SH_WBWGA .
  types:
  begin of TS_VL_SH_WBWGB,
     MATKL type C length 9,
     WGBEZ type C length 20,
     ABTNR type C length 4,
  end of TS_VL_SH_WBWGB .
  types:
TT_VL_SH_WBWGB type standard table of TS_VL_SH_WBWGB .
  types:
  begin of TS_VL_SH_WBWGC,
     MATKL type C length 9,
     WGBEZ type C length 20,
     SPART type C length 2,
  end of TS_VL_SH_WBWGC .
  types:
TT_VL_SH_WBWGC type standard table of TS_VL_SH_WBWGC .
  types:
  begin of TS_VL_SH_WBWGD,
     MATKL type C length 9,
     WGBEZ type C length 20,
     WWGDA type C length 40,
     WWGPA type C length 40,
  end of TS_VL_SH_WBWGD .
  types:
TT_VL_SH_WBWGD type standard table of TS_VL_SH_WBWGD .
  types:
  begin of TS_VL_SH_WBWGE,
     CLINT type C length 10,
     KLART type C length 3,
     KLPOS type C length 2,
     CLASS type C length 18,
     KSCHL type C length 40,
     KSCHG type C length 40,
     SPRAS type C length 2,
  end of TS_VL_SH_WBWGE .
  types:
TT_VL_SH_WBWGE type standard table of TS_VL_SH_WBWGE .
  types:
  begin of TS_VL_SH_WRF_MAT_CHAR_VAL,
     MATNR type C length 40,
     MAKTG type C length 40,
     COLOR type C length 18,
     SIZE1 type C length 18,
     SIZE2 type C length 18,
  end of TS_VL_SH_WRF_MAT_CHAR_VAL .
  types:
TT_VL_SH_WRF_MAT_CHAR_VAL type standard table of TS_VL_SH_WRF_MAT_CHAR_VAL .
  types:
  begin of TS_VL_SH_XCPDXSS_WORK_ITEM,
     WORKITEM type C length 10,
     WORKPACKAGE type C length 50,
     WORKITEMNAME type C length 40,
     WORKITEMISINACTIVE type C length 1,
  end of TS_VL_SH_XCPDXSS_WORK_ITEM .
  types:
TT_VL_SH_XCPDXSS_WORK_ITEM type standard table of TS_VL_SH_XCPDXSS_WORK_ITEM .
  types:
  begin of TS_VL_SH_XCPDXSS_WORK_ITEM_CUS,
     WORKITEM_ID type C length 10,
     WORKITEM_NAME type C length 40,
  end of TS_VL_SH_XCPDXSS_WORK_ITEM_CUS .
  types:
TT_VL_SH_XCPDXSS_WORK_ITEM_CUS type standard table of TS_VL_SH_XCPDXSS_WORK_ITEM_CUS .
  types:
  begin of TS_VL_SH_XSAPCEXFKRU_BUPA_MISC,
     MC_NAME1 type C length 35,
     MC_NAME2 type C length 35,
     POST_CODE1 type C length 10,
     MC_CITY1 type C length 25,
     MC_STREET type C length 25,
     HOUSE_NUM1 type C length 10,
     _SAPCE_FKRU_IND type C length 10,
     _SAPCE_FKRU_MIN type C length 5,
     _SAPCE_FKRU_MIN7 type C length 7,
     _SAPCE_FKRU_COT type C length 2,
     _SAPCE_FKRU_BLO type C length 1,
     PARTNER type C length 10,
  end of TS_VL_SH_XSAPCEXFKRU_BUPA_MISC .
  types:
TT_VL_SH_XSAPCEXFKRU_BUPA_MISC type standard table of TS_VL_SH_XSAPCEXFKRU_BUPA_MISC .
  types:
  begin of TS_VL_SH_XSHCMXEMPLOYMENTBASIC,
     EMPLOYEEFULLNAME type C length 80,
     EMPLOYMENTINTERNALID type C length 8,
     COMPANYCODE type C length 4,
     COMPANYCODENAME type C length 25,
     COSTCENTER type C length 10,
     COSTCENTERNAME type C length 20,
     USERID type C length 12,
     ORGANIZATIONALUNITNAME type C length 25,
     JOBNAME type C length 25,
     GIVENNAME type C length 35,
     FAMILYNAME type C length 35,
     EMPLOYEE type C length 60,
  end of TS_VL_SH_XSHCMXEMPLOYMENTBASIC .
  types:
TT_VL_SH_XSHCMXEMPLOYMENTBASIC type standard table of TS_VL_SH_XSHCMXEMPLOYMENTBASIC .
  types:
  begin of TS_VL_SH_XSTTPECXH_DEBIK,
     BEGRU type C length 4,
     KTOKD type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     KUNNR type C length 10,
  end of TS_VL_SH_XSTTPECXH_DEBIK .
  types:
TT_VL_SH_XSTTPECXH_DEBIK type standard table of TS_VL_SH_XSTTPECXH_DEBIK .
  types:
  begin of TS_VL_SH_XSTTPECXH_KREDA,
     BEGRU type C length 4,
     KTOKK type C length 4,
     SORTL type C length 10,
     LAND1 type C length 3,
     PSTLZ type C length 10,
     MCOD3 type C length 25,
     MCOD1 type C length 25,
     LIFNR type C length 10,
     LOEVM type FLAG,
  end of TS_VL_SH_XSTTPECXH_KREDA .
  types:
TT_VL_SH_XSTTPECXH_KREDA type standard table of TS_VL_SH_XSTTPECXH_KREDA .
  types:
     TS_VALUEHELPRESULT type FAC_S_VH_RESULT .
  types:
TT_VALUEHELPRESULT type standard table of TS_VALUEHELPRESULT .

  constants GC_VL_SH_H_T685 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T685' ##NO_TEXT.
  constants GC_VL_SH_H_T171 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T171' ##NO_TEXT.
  constants GC_VL_SH_H_T856 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T856' ##NO_TEXT.
  constants GC_VL_SH_H_T880 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T880' ##NO_TEXT.
  constants GC_VL_SH_H_T151 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T151' ##NO_TEXT.
  constants GC_VL_SH_H_T077S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T077S' ##NO_TEXT.
  constants GC_VL_SH_H_T077K type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T077K' ##NO_TEXT.
  constants GC_VL_SH_H_T077D type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T077D' ##NO_TEXT.
  constants GC_VL_SH_H_T881 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T881' ##NO_TEXT.
  constants GC_VL_SH_H_T8JF type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T8JF' ##NO_TEXT.
  constants GC_VL_SH_H_T8JJ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T8JJ' ##NO_TEXT.
  constants GC_VL_SH_H_T8JV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T8JV' ##NO_TEXT.
  constants GC_VL_SH_H_TATYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TATYP' ##NO_TEXT.
  constants GC_VL_SH_H_TGSB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TGSB' ##NO_TEXT.
  constants GC_VL_SH_H_TKA01 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TKA01' ##NO_TEXT.
  constants GC_VL_SH_H_TNLS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TNLS' ##NO_TEXT.
  constants GC_VL_SH_H_TSOTD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TSOTD' ##NO_TEXT.
  constants GC_VL_SH_H_T074U type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T074U' ##NO_TEXT.
  constants GC_VL_SH_H_T053R type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T053R' ##NO_TEXT.
  constants GC_VL_SH_H_T047M type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T047M' ##NO_TEXT.
  constants GC_VL_SH_H_T042Z type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T042Z' ##NO_TEXT.
  constants GC_VL_SH_H_T040S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T040S' ##NO_TEXT.
  constants GC_VL_SH_H_T040 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T040' ##NO_TEXT.
  constants GC_VL_SH_H_T028H type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T028H' ##NO_TEXT.
  constants GC_VL_SH_H_T028G type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T028G' ##NO_TEXT.
  constants GC_VL_SH_H_T028D type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T028D' ##NO_TEXT.
  constants GC_VL_SH_H_T023 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T023' ##NO_TEXT.
  constants GC_VL_SH_H_T016 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T016' ##NO_TEXT.
  constants GC_VL_SH_H_T015L type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T015L' ##NO_TEXT.
  constants GC_VL_SH_H_T014 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T014' ##NO_TEXT.
  constants GC_VL_SH_H_T012K_BAM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T012K_BAM' ##NO_TEXT.
  constants GC_VL_SH_H_T012K type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T012K' ##NO_TEXT.
  constants GC_VL_SH_H_T012 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T012' ##NO_TEXT.
  constants GC_VL_SH_H_T006 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T006' ##NO_TEXT.
  constants GC_VL_SH_H_T005 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T005' ##NO_TEXT.
  constants GC_VL_SH_MAT1F type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1F' ##NO_TEXT.
  constants GC_VL_SH_MAT1E type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1E' ##NO_TEXT.
  constants GC_VL_SH_MAT1C type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1C' ##NO_TEXT.
  constants GC_VL_SH_MAT1B type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1B' ##NO_TEXT.
  constants GC_VL_SH_MAT1A type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1A' ##NO_TEXT.
  constants GC_VL_SH_MAT0M type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT0M' ##NO_TEXT.
  constants GC_VL_SH_LARTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_LARTS' ##NO_TEXT.
  constants GC_VL_SH_LARTN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_LARTN' ##NO_TEXT.
  constants GC_VL_SH_KRED_ES_SIMPLE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KRED_ES_SIMPLE' ##NO_TEXT.
  constants GC_VL_SH_KRED_ES_ADVANCED type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KRED_ES_ADVANCED' ##NO_TEXT.
  constants GC_VL_SH_KREDY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDY' ##NO_TEXT.
  constants GC_VL_SH_KREDX type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDX' ##NO_TEXT.
  constants GC_VL_SH_KREDW type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDW' ##NO_TEXT.
  constants GC_VL_SH_KREDT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDT' ##NO_TEXT.
  constants GC_VL_SH_KREDP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDP' ##NO_TEXT.
  constants GC_VL_SH_KREDM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDM' ##NO_TEXT.
  constants GC_VL_SH_KREDL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDL' ##NO_TEXT.
  constants GC_VL_SH_KREDK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDK' ##NO_TEXT.
  constants GC_VL_SH_KREDI type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDI' ##NO_TEXT.
  constants GC_VL_SH_KREDE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDE' ##NO_TEXT.
  constants GC_VL_SH_KREDA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KREDA' ##NO_TEXT.
  constants GC_VL_SH_KOSTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KOSTS' ##NO_TEXT.
  constants GC_VL_SH_KOSTN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KOSTN' ##NO_TEXT.
  constants GC_VL_SH_KOSTD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_KOSTD' ##NO_TEXT.
  constants GC_VL_SH_JVH_VPTNR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_JVH_VPTNR' ##NO_TEXT.
  constants GC_VL_SH_JVH_KOSTG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_JVH_KOSTG' ##NO_TEXT.
  constants GC_VL_SH_H_VIBEBE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_VIBEBE' ##NO_TEXT.
  constants GC_VL_SH_H_TVTW type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TVTW' ##NO_TEXT.
  constants GC_VL_SH_H_TVKO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TVKO' ##NO_TEXT.
  constants GC_VL_SH_H_TVKGR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TVKGR' ##NO_TEXT.
  constants GC_VL_SH_H_TVFK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TVFK' ##NO_TEXT.
  constants GC_VL_SH_H_TVBUR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TVBUR' ##NO_TEXT.
  constants GC_VL_SH_H_TVBO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TVBO' ##NO_TEXT.
  constants GC_VL_SH_H_TTXJ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TTXJ' ##NO_TEXT.
  constants GC_VL_SH_H_TSPA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_TSPA' ##NO_TEXT.
  constants GC_VL_SH_H_T004V type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T004V' ##NO_TEXT.
  constants GC_VL_SH_FKKVT_F4_DDL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FKKVT_F4_DDL' ##NO_TEXT.
  constants GC_VL_SH_FKKVT_F4_BEZ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FKKVT_F4_BEZ' ##NO_TEXT.
  constants GC_VL_SH_FI_UMKRS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FI_UMKRS' ##NO_TEXT.
  constants GC_VL_SH_FIS_TMPL_SH_APPCODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FIS_TMPL_SH_APPCODE' ##NO_TEXT.
  constants GC_VL_SH_FINS_LEDGER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FINS_LEDGER' ##NO_TEXT.
  constants GC_VL_SH_FIKR_ELM_BELNR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FIKR_ELM_BELNR' ##NO_TEXT.
  constants GC_VL_SH_FEB_SH_OI_ALG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FEB_SH_OI_ALG' ##NO_TEXT.
  constants GC_VL_SH_FDMO_USER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FDMO_USER' ##NO_TEXT.
  constants GC_VL_SH_FDMO_REASON_CODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FDMO_REASON_CODE' ##NO_TEXT.
  constants GC_VL_SH_FDMO_CASE_PRIORITY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FDMO_CASE_PRIORITY' ##NO_TEXT.
  constants GC_VL_SH_FCO_SHLP_SRVDOC_TYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FCO_SHLP_SRVDOC_TYPE' ##NO_TEXT.
  constants GC_VL_SH_FCO_SHLP_SRVDOC_ITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FCO_SHLP_SRVDOC_ITEM' ##NO_TEXT.
  constants GC_VL_SH_FCO_SHLP_SRVDOC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FCO_SHLP_SRVDOC' ##NO_TEXT.
  constants GC_VL_SH_FCO_SHLP_SOLUTION_ORD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FCO_SHLP_SOLUTION_ORDER' ##NO_TEXT.
  constants GC_VL_SH_FCLM_BAM_SHLP_ACNTNUM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FCLM_BAM_SHLP_ACNTNUM' ##NO_TEXT.
  constants GC_VL_SH_FCLM_BAM_SHLP_ACC_TYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FCLM_BAM_SHLP_ACC_TYPE' ##NO_TEXT.
  constants GC_VL_SH_FAR_PYADV_SH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAR_PYADV_SH' ##NO_TEXT.
  constants GC_VL_SH_FARP_ZLSCH_BY_BUKRS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FARP_ZLSCH_BY_BUKRS' ##NO_TEXT.
  constants GC_VL_SH_FARP_HOUSEBANK_VH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FARP_HOUSEBANK_VH' ##NO_TEXT.
  constants GC_VL_SH_FAGL_LEDGERGROUP_WITH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAGL_LEDGERGROUP_WITH_APPEND' ##NO_TEXT.
  constants GC_VL_SH_FAC_WHTX_CODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_WHTX_CODE' ##NO_TEXT.
  constants GC_VL_SH_FAC_VENDOR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_VENDOR' ##NO_TEXT.
  constants GC_VL_SH_FAC_UMSKZ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_UMSKZ' ##NO_TEXT.
  constants GC_VL_SH_FAC_TAX_JURISDICTION_ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_TAX_JURISDICTION_CODE' ##NO_TEXT.
  constants GC_VL_SH_FAC_TAX_JURISDICTION type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_TAX_JURISDICTION_CODE_EXT' ##NO_TEXT.
  constants GC_VL_SH_FAC_SUBASSET type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_SUBASSET' ##NO_TEXT.
  constants GC_VL_SH_FAC_SH_DOWN_PAYMENTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_SH_DOWN_PAYMENTS' ##NO_TEXT.
  constants GC_VL_SH_FAC_SEGMENT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_SEGMENT' ##NO_TEXT.
  constants GC_VL_SH_FAC_SALES_ORDER_ITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_SALES_ORDER_ITEM' ##NO_TEXT.
  constants GC_VL_SH_FAC_SALES_ORDER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_SALES_ORDER' ##NO_TEXT.
  constants GC_VL_SH_FAC_REVERSAL_REASON type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_REVERSAL_REASON' ##NO_TEXT.
  constants GC_VL_SH_FAC_RECON_ACCT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_RECON_ACCT' ##NO_TEXT.
  constants GC_VL_SH_FAC_PURCHASING_DOC_IT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_PURCHASING_DOC_ITEM' ##NO_TEXT.
  constants GC_VL_SH_FAC_PURCHASING_DOC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_PURCHASING_DOC' ##NO_TEXT.
  constants GC_VL_SH_FAC_PS_POSID type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_PS_POSID' ##NO_TEXT.
  constants GC_VL_SH_H_T004 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T004' ##NO_TEXT.
  constants GC_VL_SH_H_T003 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T003' ##NO_TEXT.
  constants GC_VL_SH_H_T002 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T002' ##NO_TEXT.
  constants GC_VL_SH_H_T001W type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T001W' ##NO_TEXT.
  constants GC_VL_SH_H_T001S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T001S' ##NO_TEXT.
  constants GC_VL_SH_H_T001 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_T001' ##NO_TEXT.
  constants GC_VL_SH_H_RFCDEST type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_RFCDEST' ##NO_TEXT.
  constants GC_VL_SH_H_FARP_T008 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_FARP_T008' ##NO_TEXT.
  constants GC_VL_SH_H_FAGL_SEGM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_FAGL_SEGM' ##NO_TEXT.
  constants GC_VL_SH_H_EKPO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_EKPO' ##NO_TEXT.
  constants GC_VL_SH_H_AVKOA_FEB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_H_AVKOA_FEB' ##NO_TEXT.
  constants GC_VL_SH_HRPADUN_KOSTWO2 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_HRPADUN_KOSTWO2' ##NO_TEXT.
  constants GC_VL_SH_GLO_SH_BUPLA_ID type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_GLO_SH_BUPLA_ID' ##NO_TEXT.
  constants GC_VL_SH_GLO_SH_BRNCH_ID type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_GLO_SH_BRNCH_ID' ##NO_TEXT.
  constants GC_VL_SH_FSHH_MATNR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FSHH_MATNR' ##NO_TEXT.
  constants GC_VL_SH_FSBP_BUPAG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FSBP_BUPAG' ##NO_TEXT.
  constants GC_VL_SH_FSBP_BP_IDNUM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FSBP_BP_IDNUM' ##NO_TEXT.
  constants GC_VL_SH_FSBP_ALIAS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FSBP_ALIAS' ##NO_TEXT.
  constants GC_VL_SH_FOT_TXA_F4_TAX_CODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FOT_TXA_F4_TAX_CODE' ##NO_TEXT.
  constants GC_VL_SH_FOT_TXA_F4_FRGN_REGIS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FOT_TXA_F4_FRGN_REGISTRATIONS' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_GEN_Z type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_GEN_Z' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_GEN_P type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_GEN_P' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_GEN_K type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_GEN_K' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_GEN_H type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_GEN_H' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_GEN_C type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_GEN_C' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_GEN_B type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_GEN_B' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_GEN_A type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_GEN_A' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_ES_HDR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_ES_HDR' ##NO_TEXT.
  constants GC_VL_SH_FM_RESERV_ES_AA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_RESERV_ES_AA' ##NO_TEXT.
  constants GC_VL_SH_FM_KREDI_FMPSOIS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_KREDI_FMPSOIS' ##NO_TEXT.
  constants GC_VL_SH_FM_DEBI_FMPSOIS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FM_DEBI_FMPSOIS' ##NO_TEXT.
  constants GC_VL_SH_FKK_RECENT_VTKEY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FKK_RECENT_VTKEY' ##NO_TEXT.
  constants GC_VL_SH_FKK_RECENT_GPART type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FKK_RECENT_GPART' ##NO_TEXT.
  constants GC_VL_SH_FKK_CM_CPERS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FKK_CM_CPERS' ##NO_TEXT.
  constants GC_VL_SH_FKKVT_F4_TR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FKKVT_F4_TR' ##NO_TEXT.
  constants GC_VL_SH_RESCSUA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RESCSUA' ##NO_TEXT.
  constants GC_VL_SH_RESCSCKEYB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RESCSCKEYB' ##NO_TEXT.
  constants GC_VL_SH_RESCSCKEYA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RESCSCKEYA' ##NO_TEXT.
  constants GC_VL_SH_RELIFNRCN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RELIFNRCN' ##NO_TEXT.
  constants GC_VL_SH_REKUNNR_VIRAINV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REKUNNR_VIRAINV' ##NO_TEXT.
  constants GC_VL_SH_REKUNNRCN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REKUNNRCN' ##NO_TEXT.
  constants GC_VL_SH_RECNCNSE2 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNSE2' ##NO_TEXT.
  constants GC_VL_SH_RECNCNSE1 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNSE1' ##NO_TEXT.
  constants GC_VL_SH_RECNCNK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNK' ##NO_TEXT.
  constants GC_VL_SH_RECNCNINV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNINV' ##NO_TEXT.
  constants GC_VL_SH_RECNCNH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNH' ##NO_TEXT.
  constants GC_VL_SH_RECNCNG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNG' ##NO_TEXT.
  constants GC_VL_SH_RECNCNF type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNF' ##NO_TEXT.
  constants GC_VL_SH_RECNCNE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNE' ##NO_TEXT.
  constants GC_VL_SH_RECNCND type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCND' ##NO_TEXT.
  constants GC_VL_SH_RECNCNB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNB' ##NO_TEXT.
  constants GC_VL_SH_RECNCNA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RECNCNA' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOT' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOP' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOOO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOOO' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOOC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOOC' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOOA' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOO' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOMS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOMS' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOH' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOG' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOE' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOD' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOC' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOB' ##NO_TEXT.
  constants GC_VL_SH_REBDRONOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDRONOA' ##NO_TEXT.
  constants GC_VL_SH_REBDPRNOP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDPRNOP' ##NO_TEXT.
  constants GC_VL_SH_REBDPRNOOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDPRNOOA' ##NO_TEXT.
  constants GC_VL_SH_REBDPRNOO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDPRNOO' ##NO_TEXT.
  constants GC_VL_SH_REBDPRNOG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDPRNOG' ##NO_TEXT.
  constants GC_WORKFLOWSTATUS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'WorkflowStatus' ##NO_TEXT.
  constants GC_VL_SH_XSTTPECXH_KREDA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_xSTTPECxH_KREDA' ##NO_TEXT.
  constants GC_VL_SH_XSTTPECXH_DEBIK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_xSTTPECxH_DEBIK' ##NO_TEXT.
  constants GC_VL_SH_XSHCMXEMPLOYMENTBASIC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_xSHCMxEMPLOYMENTBASIC' ##NO_TEXT.
  constants GC_VL_SH_XSAPCEXFKRU_BUPA_MISC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_xSAPCExFKRU_BUPA_MISC' ##NO_TEXT.
  constants GC_VL_SH_XCPDXSS_WORK_ITEM_CUS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_xCPDxSS_WORK_ITEM_CUST' ##NO_TEXT.
  constants GC_VL_SH_XCPDXSS_WORK_ITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_xCPDxSS_WORK_ITEM' ##NO_TEXT.
  constants GC_VL_SH_WRF_MAT_CHAR_VAL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_WRF_MAT_CHAR_VAL' ##NO_TEXT.
  constants GC_VL_SH_WBWGE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_WBWGE' ##NO_TEXT.
  constants GC_VL_SH_WBWGD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_WBWGD' ##NO_TEXT.
  constants GC_VL_SH_WBWGC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_WBWGC' ##NO_TEXT.
  constants GC_VL_SH_WBWGB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_WBWGB' ##NO_TEXT.
  constants GC_VL_SH_WBWGA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_WBWGA' ##NO_TEXT.
  constants GC_VL_SH_VLCBUPAS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_VLCBUPAS' ##NO_TEXT.
  constants GC_VL_SH_VLCBUPAP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_VLCBUPAP' ##NO_TEXT.
  constants GC_VL_SH_VLCBUPAB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_VLCBUPAB' ##NO_TEXT.
  constants GC_VL_SH_VLCBUPAA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_VLCBUPAA' ##NO_TEXT.
  constants GC_VL_SH_SH_TCURC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_TCURC' ##NO_TEXT.
  constants GC_VL_SH_SH_T028D type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_T028D' ##NO_TEXT.
  constants GC_VL_SH_SH_T007A type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_T007A' ##NO_TEXT.
  constants GC_VL_SH_SH_REPRO_REASON_CODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_REPRO_REASON_CODE' ##NO_TEXT.
  constants GC_VL_SH_SH_PABKS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_PABKS' ##NO_TEXT.
  constants GC_VL_SH_SH_GMGR_S4C_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_GMGR_S4C_CDS' ##NO_TEXT.
  constants GC_VL_SH_SH_FMFUND_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_FMFUND_CDS' ##NO_TEXT.
  constants GC_VL_SH_SH_FMFUNDSMGMTFUNCARE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_FMFUNDSMGMTFUNCAREA_CDS' ##NO_TEXT.
  constants GC_VL_SH_SH_FMFUNDEDPRG_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_FMFUNDEDPRG_CDS' ##NO_TEXT.
  constants GC_VL_SH_SH_FMFCTR_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_FMFCTR_CDS' ##NO_TEXT.
  constants GC_VL_SH_SH_FMCI_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_FMCI_CDS' ##NO_TEXT.
  constants GC_VL_SH_SH_FMBPD_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_FMBPD_CDS' ##NO_TEXT.
  constants GC_VL_SH_SH_FMAREA_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SH_FMAREA_CDS' ##NO_TEXT.
  constants GC_VL_SH_SGT_MATNR_S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SGT_MATNR_S' ##NO_TEXT.
  constants GC_VL_SH_SECCODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_SECCODE' ##NO_TEXT.
  constants GC_VL_SH_RESCSUG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RESCSUG' ##NO_TEXT.
  constants GC_VL_SH_RESCSUC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RESCSUC' ##NO_TEXT.
  constants GC_VL_SH_RESCSUB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_RESCSUB' ##NO_TEXT.
  constants GC_VL_SH_REBDPRNOE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDPRNOE' ##NO_TEXT.
  constants GC_VL_SH_MEKKT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKT' ##NO_TEXT.
  constants GC_VL_SH_MEKKS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKS' ##NO_TEXT.
  constants GC_VL_SH_MEKKP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKP' ##NO_TEXT.
  constants GC_VL_SH_MEKKN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKN' ##NO_TEXT.
  constants GC_VL_SH_MEKKM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKM' ##NO_TEXT.
  constants GC_VL_SH_MEKKL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKL' ##NO_TEXT.
  constants GC_VL_SH_MEKKK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKK' ##NO_TEXT.
  constants GC_VL_SH_MEKKI type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKI' ##NO_TEXT.
  constants GC_VL_SH_MEKKH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKH' ##NO_TEXT.
  constants GC_VL_SH_MEKKG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKG' ##NO_TEXT.
  constants GC_VL_SH_MEKKE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKE' ##NO_TEXT.
  constants GC_VL_SH_MEKKD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKD' ##NO_TEXT.
  constants GC_VL_SH_MEKKC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKC' ##NO_TEXT.
  constants GC_VL_SH_MEKKB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKB' ##NO_TEXT.
  constants GC_VL_SH_MEKKA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKA' ##NO_TEXT.
  constants GC_VL_SH_MAT6MPN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT6MPN' ##NO_TEXT.
  constants GC_VL_SH_MAT5MPN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT5MPN' ##NO_TEXT.
  constants GC_VL_SH_MAT4MPN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT4MPN' ##NO_TEXT.
  constants GC_VL_SH_MAT3MPN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT3MPN' ##NO_TEXT.
  constants GC_VL_SH_MAT2MPN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT2MPN' ##NO_TEXT.
  constants GC_VL_SH_MAT1_TREX_SIMPLE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1_TREX_SIMPLE' ##NO_TEXT.
  constants GC_VL_SH_MAT1_TREX_ADVANCED type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1_TREX_ADVANCED' ##NO_TEXT.
  constants GC_VL_SH_MAT1_ESH_TREX_BASIC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1_ESH_TREX_BASIC' ##NO_TEXT.
  constants GC_VL_SH_MAT1W type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1W' ##NO_TEXT.
  constants GC_VL_SH_MAT1V type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1V' ##NO_TEXT.
  constants GC_VL_SH_MAT1T type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1T' ##NO_TEXT.
  constants GC_VL_SH_MAT1S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1S' ##NO_TEXT.
  constants GC_VL_SH_MAT1R type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1R' ##NO_TEXT.
  constants GC_VL_SH_MAT1P type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1P' ##NO_TEXT.
  constants GC_VL_SH_MAT1N type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1N' ##NO_TEXT.
  constants GC_VL_SH_MAT1MPN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1MPN' ##NO_TEXT.
  constants GC_VL_SH_MAT1L type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1L' ##NO_TEXT.
  constants GC_VL_SH_MAT1J type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1J' ##NO_TEXT.
  constants GC_VL_SH_MAT1I type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1I' ##NO_TEXT.
  constants GC_VL_SH_MAT1H type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MAT1H' ##NO_TEXT.
  constants GC_VL_SH_REBDPRNOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDPRNOA' ##NO_TEXT.
  constants GC_VL_SH_REBDBUNOP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBUNOP' ##NO_TEXT.
  constants GC_VL_SH_REBDBUNOOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBUNOOA' ##NO_TEXT.
  constants GC_VL_SH_REBDBUNOO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBUNOO' ##NO_TEXT.
  constants GC_VL_SH_REBDBUNOG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBUNOG' ##NO_TEXT.
  constants GC_VL_SH_REBDBUNOE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBUNOE' ##NO_TEXT.
  constants GC_VL_SH_REBDBUNOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBUNOA' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOSE2 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOSE2' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOSE1 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOSE1' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOP' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOOA' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOO' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOF type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOF' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOE' ##NO_TEXT.
  constants GC_VL_SH_REBDBENOA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_REBDBENOA' ##NO_TEXT.
  constants GC_VL_SH_ORDEU type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDEU' ##NO_TEXT.
  constants GC_VL_SH_ORDET type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDET' ##NO_TEXT.
  constants GC_VL_SH_ORDES type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDES' ##NO_TEXT.
  constants GC_VL_SH_ORDER_SES_QUICK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDER_SES_QUICK' ##NO_TEXT.
  constants GC_VL_SH_ORDER_SES_ADVANCED type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDER_SES_ADVANCED' ##NO_TEXT.
  constants GC_VL_SH_ORDEF type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDEF' ##NO_TEXT.
  constants GC_VL_SH_ORDED type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDED' ##NO_TEXT.
  constants GC_VL_SH_ORDEC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDEC' ##NO_TEXT.
  constants GC_VL_SH_ORDEB_TYPEAHEAD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDEB_TYPEAHEAD' ##NO_TEXT.
  constants GC_VL_SH_ORDEB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDEB' ##NO_TEXT.
  constants GC_VL_SH_ORDEA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_ORDEA' ##NO_TEXT.
  constants GC_VL_SH_MPNKRED1 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MPNKRED1' ##NO_TEXT.
  constants GC_VL_SH_MMBSI_MEKK_TREX_CC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MMBSI_MEKK_TREX_CC' ##NO_TEXT.
  constants GC_VL_SH_MMBSI_MEKK_DBSH_CC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MMBSI_MEKK_DBSH_CC' ##NO_TEXT.
  constants GC_VL_SH_MEKK_TREX_SIMPLE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKK_TREX_SIMPLE' ##NO_TEXT.
  constants GC_VL_SH_MEKK_TREX_ADVANCED type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKK_TREX_ADVANCED' ##NO_TEXT.
  constants GC_VL_SH_MEKK_TM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKK_TM' ##NO_TEXT.
  constants GC_VL_SH_MEKKW type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKW' ##NO_TEXT.
  constants GC_VL_SH_MEKKV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKV' ##NO_TEXT.
  constants GC_VL_SH_MEKKU type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_MEKKU' ##NO_TEXT.
  constants GC_LANGUAGE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Language' ##NO_TEXT.
  constants GC_I_TH_BRANCHCODEVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_TH_BranchCodeVHType' ##NO_TEXT.
  constants GC_LOCKBOXWORKLISTITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'LockboxWorklistItem' ##NO_TEXT.
  constants GC_MDADDRESS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'MDAddress' ##NO_TEXT.
  constants GC_I_SUPPLIER_VHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_Supplier_VHType' ##NO_TEXT.
  constants GC_I_PAYTFILEALLOCALGORITHMVHT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_PaytFileAllocAlgorithmVHType' ##NO_TEXT.
  constants GC_I_PAYTADVICEACCOUNTTYPETEXT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_PaytAdviceAccountTypeTextType' ##NO_TEXT.
  constants GC_I_PAYTADVICEACCOUNTTYPESTDV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_PaytAdviceAccountTypeStdVHType' ##NO_TEXT.
  constants GC_NOTE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Note' ##NO_TEXT.
  constants GC_OPENITEMREFERENCE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'OpenItemReference' ##NO_TEXT.
  constants GC_RECRRGACCTGDOCOCCURRENCE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'RecrrgAcctgDocOccurrence' ##NO_TEXT.
  constants GC_RECRRGACCTGDOCWORKLISTITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'RecrrgAcctgDocWorklistItem' ##NO_TEXT.
  constants GC_RECURRENCEDEFINITION type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'RecurrenceDefinition' ##NO_TEXT.
  constants GC_SAP__COVERPAGE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__CoverPage' ##NO_TEXT.
  constants GC_SAP__DOCUMENTDESCRIPTION type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__DocumentDescription' ##NO_TEXT.
  constants GC_SAP__FITTOPAGE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__FitToPage' ##NO_TEXT.
  constants GC_SAP__FORMAT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__Format' ##NO_TEXT.
  constants GC_I_PAYMENTCLEARINGGROUPVHTYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_PaymentClearingGroupVHType' ##NO_TEXT.
  constants GC_I_LANGUAGETYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_LanguageType' ##NO_TEXT.
  constants GC_I_INTERPRETATIONALGORITHMVH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_InterpretationAlgorithmVHType' ##NO_TEXT.
  constants GC_I_HOUSEBANKSTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_HouseBankStdVHType' ##NO_TEXT.
  constants GC_I_HOUSEBANKACCOUNTVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_HouseBankAccountVHType' ##NO_TEXT.
  constants GC_I_GLACCOUNTSTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_GLAccountStdVHType' ##NO_TEXT.
  constants GC_I_CUSTOMER_VHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_Customer_VHType' ##NO_TEXT.
  constants GC_I_CREDITCONTROLAREASTDVHTYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_CreditControlAreaStdVHType' ##NO_TEXT.
  constants GC_I_COSTCENTERSTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_CostCenterStdVHType' ##NO_TEXT.
  constants GC_I_CONTROLLINGAREASTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_ControllingAreaStdVHType' ##NO_TEXT.
  constants GC_I_COMPANYCODETYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_CompanyCodeType' ##NO_TEXT.
  constants GC_I_COMPANYCODESTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_CompanyCodeStdVHType' ##NO_TEXT.
  constants GC_I_CHARTOFACCOUNTSSTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_ChartOfAccountsStdVHType' ##NO_TEXT.
  constants GC_I_BUSINESSAREASTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_BusinessAreaStdVHType' ##NO_TEXT.
  constants GC_I_BANKSTMNTITMREPROCESSRSNN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_BankStmntItmReprocessRsnNameType' ##NO_TEXT.
  constants GC_I_BANKSTMNTITEMREPROCESSREA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_BankStmntItemReprocessReasonType' ##NO_TEXT.
  constants GC_I_BANKSTATEMENTVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_BankStatementVHType' ##NO_TEXT.
  constants GC_I_BANKACCTNUMBERVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_BankAcctNumberVHType' ##NO_TEXT.
  constants GC_VL_CT_T009 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T009' ##NO_TEXT.
  constants GC_VL_CT_T008 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T008' ##NO_TEXT.
  constants GC_VL_CT_T005S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T005S' ##NO_TEXT.
  constants GC_VL_CT_T005 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T005' ##NO_TEXT.
  constants GC_VL_CT_J_1AGICD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_J_1AGICD' ##NO_TEXT.
  constants GC_VL_CT_J_1ADTYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_J_1ADTYP' ##NO_TEXT.
  constants GC_VL_CT_FINSC_CURTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_FINSC_CURTYPE' ##NO_TEXT.
  constants GC_VL_CT_FEB_REPRO_RRC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_FEB_REPRO_RRC' ##NO_TEXT.
  constants GC_VL_CT_FCLM_BAM_AMD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_FCLM_BAM_AMD' ##NO_TEXT.
  constants GC_VL_CT_FCLM_BAM_AC_TYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_FCLM_BAM_AC_TYPE' ##NO_TEXT.
  constants GC_VL_CT_FAR_PYMT_CLG_GRP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_FAR_PYMT_CLG_GRP' ##NO_TEXT.
  constants GC_VL_CT_FAGL_TLDGRP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_FAGL_TLDGRP' ##NO_TEXT.
  constants GC_VL_CT_CMIS_L_FS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_CMIS_L_FS' ##NO_TEXT.
  constants GC_VL_CT_CEPC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_CEPC' ##NO_TEXT.
  constants GC_VL_CT_CBPR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_CBPR' ##NO_TEXT.
  constants GC_VL_CT_ADRC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_ADRC' ##NO_TEXT.
  constants GC_VL_CH_TBE11 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_TBE11' ##NO_TEXT.
  constants GC_VL_CH_PRPS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_PRPS' ##NO_TEXT.
  constants GC_VL_CH_PBUSINESSPLACE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_PBUSINESSPLACE' ##NO_TEXT.
  constants GC_VL_CH_FMFXPO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_FMFXPO' ##NO_TEXT.
  constants GC_VL_CH_DD03L type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_DD03L' ##NO_TEXT.
  constants GC_VL_CH_CKPH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_CKPH' ##NO_TEXT.
  constants GC_VL_CH_BNKA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_BNKA' ##NO_TEXT.
  constants GC_VL_CH_BALHDR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_BALHDR' ##NO_TEXT.
  constants GC_VL_CH_ANLH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CH_ANLH' ##NO_TEXT.
  constants GC_VHLOCKBOXNUMBER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VHLockboxNumber' ##NO_TEXT.
  constants GC_VHGLACCOUNTFORINPUT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VHGLAccountForInput' ##NO_TEXT.
  constants GC_VALUEHELPRESULT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ValueHelpResult' ##NO_TEXT.
  constants GC_UPLOADEDDOCWORKLISTITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'UploadedDocWorklistItem' ##NO_TEXT.
  constants GC_SEARCHHELPFIELD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SearchHelpField' ##NO_TEXT.
  constants GC_SCREENVARIANT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ScreenVariant' ##NO_TEXT.
  constants GC_SAP__VALUEHELP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__ValueHelp' ##NO_TEXT.
  constants GC_SAP__TABLECOLUMNS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__TableColumns' ##NO_TEXT.
  constants GC_SAP__SIGNATURE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__Signature' ##NO_TEXT.
  constants GC_SAP__PDFSTANDARD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SAP__PDFStandard' ##NO_TEXT.
  constants GC_I_BANKACCOUNTTYPEVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_BankAccountTypeVHType' ##NO_TEXT.
  constants GC_FINSPOSTINGBSITEMHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingBSItemHeader' ##NO_TEXT.
  constants GC_FINSPOSTINGBSITEMDSPHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingBSItemDspHeader' ##NO_TEXT.
  constants GC_FINSPOSTINGAPARITEMTOBECLRD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingAPARItemToBeClrd' ##NO_TEXT.
  constants GC_FINSPOSTINGAPARITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingAPARItem' ##NO_TEXT.
  constants GC_FILESHARERESOURCE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FileShareResource' ##NO_TEXT.
  constants GC_FILESHAREREPOSITORY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FileShareRepository' ##NO_TEXT.
  constants GC_FILESHARE4JOURNALENTRIES type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FileShare4JournalEntries' ##NO_TEXT.
  constants GC_FILESHARE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FileShare' ##NO_TEXT.
  constants GC_FILECONTENTFORUPLOAD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FileContentForUpload' ##NO_TEXT.
  constants GC_FILECONTENTFORDOWNLOAD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FileContentForDownload' ##NO_TEXT.
  constants GC_FAC_POST_TAX_P_GLACCT_SPRAS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FAC_POST_TAX_P_GLACCT_SPRAS_VHType' ##NO_TEXT.
  constants GC_FAC_POST_TAX_PAYABLE_GLACCT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FAC_POST_TAX_PAYABLE_GLACCT_VHType' ##NO_TEXT.
  constants GC_FAC_POST_JOUR_ENTRY_GLACCT_ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FAC_POST_JOUR_ENTRY_GLACCT_VHType' ##NO_TEXT.
  constants GC_FAC_POST_JE_GLACCT_SPRAS_VH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FAC_POST_JE_GLACCT_SPRAS_VHType' ##NO_TEXT.
  constants GC_FAC_POST_ALT_GLACCT_SPRAS_V type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FAC_POST_ALT_GLACCT_SPRAS_VHType' ##NO_TEXT.
  constants GC_FAC_POST_ALTERNATIVE_GLACCT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FAC_POST_ALTERNATIVE_GLACCT_VHType' ##NO_TEXT.
  constants GC_DISPUTE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Dispute' ##NO_TEXT.
  constants GC_C_GLACCTWTHHOUSEBANKACCTVHT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'C_GLAcctWthHouseBankAcctVHType' ##NO_TEXT.
  constants GC_C_FINPOSTINGTEMPLATETYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'C_FinPostingTemplateType' ##NO_TEXT.
  constants GC_CREATECLEARINGFOROPENITEMRE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'CreateClearingForOpenItemReturn' ##NO_TEXT.
  constants GC_BANKSTATEMENTWORKLISTITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'BankStatementWorklistItem' ##NO_TEXT.
  constants GC_ATTACHMENT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Attachment' ##NO_TEXT.
  constants GC_APARWORKLISTITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'APARWorklistItem' ##NO_TEXT.
  constants GC_APARWORKLIST type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'APARWorklist' ##NO_TEXT.
  constants GC_APAROPENITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'APAROpenItem' ##NO_TEXT.
  constants GC_ACCTGDOCTMPKEY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocTmpKey' ##NO_TEXT.
  constants GC_ACCTGDOCSIMTMPKEY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocSimTmpKey' ##NO_TEXT.
  constants GC_ACCTGDOCRESIDUALITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocResidualItem' ##NO_TEXT.
  constants GC_ACCTGDOCKEY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocKey' ##NO_TEXT.
  constants GC_ACCTGDOCHDRPAYMENTADVICE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocHdrPaymentAdvice' ##NO_TEXT.
  constants GC_ACCTGDOCHDRPAYMENT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocHdrPayment' ##NO_TEXT.
  constants GC_ACCTGDOCHDRLBITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocHdrLBItem' ##NO_TEXT.
  constants GC_ACCTGDOCHDRBSITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocHdrBSItem' ##NO_TEXT.
  constants GC_ACCTGDOCHDRBANKCHARGES type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AcctgDocHdrBankCharges' ##NO_TEXT.
  constants GC_ACCOUNTKEY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'AccountKey' ##NO_TEXT.
  constants GC_I_ARPOSTGRULEPAYTTRANSCATVH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_ARPostgRulePaytTransCatVHType' ##NO_TEXT.
  constants GC_I_ARLOCKBOXTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_ARLockboxType' ##NO_TEXT.
  constants GC_I_ALLOCATIONALGORITHMFXDVAL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_AllocationAlgorithmFxdValTxtType' ##NO_TEXT.
  constants GC_I_ALLOCATIONALGORITHMFXDVA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_AllocationAlgorithmFxdValVHType' ##NO_TEXT.
  constants GC_I_ACCOUNTINGDOCUMENTTYPETEX type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_AccountingDocumentTypeTextType' ##NO_TEXT.
  constants GC_I_ACCOUNTINGDOCUMENTTYPESTD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_AccountingDocumentTypeStdVHType' ##NO_TEXT.
  constants GC_HOLDDOCWORKLISTITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'HoldDocWorklistItem' ##NO_TEXT.
  constants GC_HOLDDOCUMENTPOSTRETURN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'HoldDocumentPostReturn' ##NO_TEXT.
  constants GC_HOLDDOCUMENTPARKRETURN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'HoldDocumentParkReturn' ##NO_TEXT.
  constants GC_HOLDDOCUMENTCOUNT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'HoldDocumentCount' ##NO_TEXT.
  constants GC_HOLDDOCKEY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'HoldDocKey' ##NO_TEXT.
  constants GC_GLOPENITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'GLOpenItem' ##NO_TEXT.
  constants GC_GLOBALIZATIONFIELDDEF type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'GlobalizationFieldDef' ##NO_TEXT.
  constants GC_GLACCOUNTWORKLISTITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'GLAccountWorklistItem' ##NO_TEXT.
  constants GC_GLACCOUNTLEDGERGROUPWORKLIS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'GLAccountLedgerGroupWorklistItem' ##NO_TEXT.
  constants GC_GLACCOUNTHOUSEBANKACCOUNTWO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'GLAccountHouseBankAccountWorklistItem' ##NO_TEXT.
  constants GC_GETAPPSETTINGS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'GetAppSettings' ##NO_TEXT.
  constants GC_FUNCTIONIMPORTSUCCESS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FunctionImportSuccess' ##NO_TEXT.
  constants GC_FUNCTIONIMPORTRETMODIFYDISP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FunctionImportRetModifyDisputes' ##NO_TEXT.
  constants GC_FUNCTIONIMPORTDUMMYRETURN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FunctionImportDummyReturn' ##NO_TEXT.
  constants GC_FINSPOSTINGWITHHOLDINGTAX type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingWithholdingTax' ##NO_TEXT.
  constants GC_FINSPOSTINGTAX type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingTax' ##NO_TEXT.
  constants GC_FINSPOSTINGPAYMENTHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingPaymentHeader' ##NO_TEXT.
  constants GC_FINSPOSTINGPAYMENTDIFFERENC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingPaymentDifference' ##NO_TEXT.
  constants GC_FINSPOSTINGPAYMENTCLEARINGH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingPaymentClearingHeader' ##NO_TEXT.
  constants GC_FINSPOSTINGPAYMENTADVICESUB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingPaymentAdviceSubItems' ##NO_TEXT.
  constants GC_FINSPOSTINGPAYMENTADVICEITE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingPaymentAdviceItems' ##NO_TEXT.
  constants GC_FINSPOSTINGPARTNERANDPAYMEN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingPartnerAndPaymentData' ##NO_TEXT.
  constants GC_FINSPOSTINGLBITEMHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingLBItemHeader' ##NO_TEXT.
  constants GC_FINSPOSTINGLBITEMDSPHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingLBItemDspHeader' ##NO_TEXT.
  constants GC_FINSPOSTINGGLITEMTOBECLRD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingGLItemToBeClrd' ##NO_TEXT.
  constants GC_FINSPOSTINGGLITEMPROFITBLTY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingGLItemProfitbltySgmt' ##NO_TEXT.
  constants GC_FINSPOSTINGGLITEM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingGLItem' ##NO_TEXT.
  constants GC_FINSPOSTINGGLHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingGLHeader' ##NO_TEXT.
  constants GC_FINSPOSTINGCLEARINGHEADER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'FinsPostingClearingHeader' ##NO_TEXT.
  constants GC_VL_SH_DEBIW type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIW' ##NO_TEXT.
  constants GC_VL_SH_DEBIT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIT' ##NO_TEXT.
  constants GC_VL_SH_DEBIS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIS' ##NO_TEXT.
  constants GC_VL_SH_DEBIR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIR' ##NO_TEXT.
  constants GC_VL_SH_DEBIQ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIQ' ##NO_TEXT.
  constants GC_VL_SH_DEBIP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIP' ##NO_TEXT.
  constants GC_VL_SH_DEBIL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIL' ##NO_TEXT.
  constants GC_VL_SH_DEBIK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIK' ##NO_TEXT.
  constants GC_VL_SH_DEBIE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIE' ##NO_TEXT.
  constants GC_VL_SH_DEBID type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBID' ##NO_TEXT.
  constants GC_VL_SH_DEBIA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIA' ##NO_TEXT.
  constants GC_VL_SH_DD_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DD_SHLP' ##NO_TEXT.
  constants GC_VL_SH_DD_DTEL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DD_DTEL' ##NO_TEXT.
  constants GC_VL_SH_CRM_BUPA_CUSTOMER_NUM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_CRM_BUPA_CUSTOMER_NUMBER' ##NO_TEXT.
  constants GC_VL_SH_CRM_BUPA_CONTACT_NUMB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_CRM_BUPA_CONTACT_NUMBER' ##NO_TEXT.
  constants GC_VL_SH_CMD_PROD_BY_PRODHIER_ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_CMD_PROD_BY_PRODHIER_SHLP' ##NO_TEXT.
  constants GC_VL_SH_BU_ADR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BU_ADR' ##NO_TEXT.
  constants GC_VL_SH_BUPA_LIFNR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPA_LIFNR' ##NO_TEXT.
  constants GC_VL_SH_BUPA_KUNNR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPA_KUNNR' ##NO_TEXT.
  constants GC_VL_SH_BUPAV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAV' ##NO_TEXT.
  constants GC_VL_SH_BUPAU type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAU' ##NO_TEXT.
  constants GC_VL_SH_BUPAT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAT' ##NO_TEXT.
  constants GC_VL_SH_BUPARLTYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPARLTYP' ##NO_TEXT.
  constants GC_VL_SH_BUPAR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAR' ##NO_TEXT.
  constants GC_VL_SH_BUPAP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAP' ##NO_TEXT.
  constants GC_VL_SH_BUPAI type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAI' ##NO_TEXT.
  constants GC_VL_SH_BUPAGUID type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAGUID' ##NO_TEXT.
  constants GC_VL_SH_BUPAB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAB' ##NO_TEXT.
  constants GC_VL_SH_BUPAA_VERS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAA_VERS' ##NO_TEXT.
  constants GC_VL_SH_BUPAA type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUPAA' ##NO_TEXT.
  constants GC_VL_SH_BUHI_TREE_SEARCH_TERM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BUHI_TREE_SEARCH_TERM3' ##NO_TEXT.
  constants GC_VL_SH_BP_ERP_TREX_SIMPLE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BP_ERP_TREX_SIMPLE' ##NO_TEXT.
  constants GC_VL_SH_BP_ERP_TREX_ADVANCED type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BP_ERP_TREX_ADVANCED' ##NO_TEXT.
  constants GC_VL_SH_BP_BUPAG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_BP_BUPAG' ##NO_TEXT.
  constants GC_VL_FV_WT_STAT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_WT_STAT' ##NO_TEXT.
  constants GC_VL_SH_FAC_PROFIT_CENTER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_PROFIT_CENTER' ##NO_TEXT.
  constants GC_VL_SH_FAC_ORDER_ACTIVITY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_ORDER_ACTIVITY' ##NO_TEXT.
  constants GC_VL_SH_FAC_ORDER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_ORDER' ##NO_TEXT.
  constants GC_VL_SH_FAC_NETWORK_ACTIVITY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_NETWORK_ACTIVITY' ##NO_TEXT.
  constants GC_VL_SH_FAC_NETWORK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_NETWORK' ##NO_TEXT.
  constants GC_VL_SH_FAC_MATERIAL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_MATERIAL' ##NO_TEXT.
  constants GC_VL_SH_FAC_HKTID_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_HKTID_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_HBKID_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_HBKID_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_GL_ACCT_WL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_GL_ACCT_WL' ##NO_TEXT.
  constants GC_VL_SH_FAC_GL_ACCT_LOCAL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_GL_ACCT_LOCAL' ##NO_TEXT.
  constants GC_VL_SH_FAC_GL_ACCT_LG_LOCAL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_GL_ACCT_LG_LOCAL' ##NO_TEXT.
  constants GC_VL_SH_FAC_GL_ACCT_LG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_GL_ACCT_LG' ##NO_TEXT.
  constants GC_VL_SH_FAC_GL_ACCT_CASH type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_GL_ACCT_CASH' ##NO_TEXT.
  constants GC_VL_SH_FAC_GL_ACCT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_GL_ACCT' ##NO_TEXT.
  constants GC_VL_SH_FAC_GL_ACCOUNT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_GL_ACCOUNT' ##NO_TEXT.
  constants GC_VL_SH_FAC_FIN_TRANSACTION_T type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_FIN_TRANSACTION_TYPE' ##NO_TEXT.
  constants GC_VL_SH_FAC_EMPFB_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_EMPFB_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_DTWS4_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_DTWS4_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_DTWS3_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_DTWS3_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_DTWS2_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_DTWS2_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_DTWS1_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_DTWS1_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_CUSTOMER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_CUSTOMER' ##NO_TEXT.
  constants GC_VL_SH_FAC_COST_OBJECT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_COST_OBJECT' ##NO_TEXT.
  constants GC_VL_SH_FAC_COST_CENTER type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_COST_CENTER' ##NO_TEXT.
  constants GC_VL_SH_FAC_BVTYP_SHLP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_BVTYP_SHLP' ##NO_TEXT.
  constants GC_VL_SH_FAC_ASSET_TRANSACTION type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_ASSET_TRANSACTION_TYPE' ##NO_TEXT.
  constants GC_VL_SH_FAC_ASSET type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_FAC_ASSET' ##NO_TEXT.
  constants GC_VL_SH_F4_BL_BANK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_F4_BL_BANK' ##NO_TEXT.
  constants GC_VL_SH_EANE_RFQ_QUOTE_H type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_EANE_RFQ_QUOTE_H' ##NO_TEXT.
  constants GC_VL_SH_DEBI_ES_SIMPLE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBI_ES_SIMPLE' ##NO_TEXT.
  constants GC_VL_SH_DEBI_ES_ADVANCED_CDS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBI_ES_ADVANCED_CDS' ##NO_TEXT.
  constants GC_VL_SH_DEBI_ES_ADVANCED type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBI_ES_ADVANCED' ##NO_TEXT.
  constants GC_VL_SH_DEBIZ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIZ' ##NO_TEXT.
  constants GC_VL_SH_DEBIY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIY' ##NO_TEXT.
  constants GC_VL_SH_DEBIX type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_SH_DEBIX' ##NO_TEXT.
  constants GC_VL_FV_SHKZG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_SHKZG' ##NO_TEXT.
  constants GC_VL_FV_FAC_RJET_TRANS_LC_AMT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FAC_RJET_TRANS_LC_AMTS' ##NO_TEXT.
  constants GC_VL_FV_FAC_RJET_RECURRENCE_T type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FAC_RJET_RECURRENCE_TYPE' ##NO_TEXT.
  constants GC_VL_FV_FAC_RJET_POSTING_STAT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FAC_RJET_POSTING_STATUS' ##NO_TEXT.
  constants GC_VL_FV_FAC_RJET_OCCUR_DAY_TY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FAC_RJET_OCCUR_DAY_TYPE' ##NO_TEXT.
  constants GC_VL_FV_FAC_RJET_END_BY_TYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FAC_RJET_END_BY_TYPE' ##NO_TEXT.
  constants GC_VL_FV_CVP_XBLCK type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_CVP_XBLCK' ##NO_TEXT.
  constants GC_VL_FV_CURTP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_CURTP' ##NO_TEXT.
  constants GC_VL_FV_CURRTYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_CURRTYP' ##NO_TEXT.
  constants GC_VL_FV_CMIS_FS_TYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_CMIS_FS_TYPE' ##NO_TEXT.
  constants GC_VL_FV_CMIS_FS_SVR_TYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_CMIS_FS_SVR_TYPE' ##NO_TEXT.
  constants GC_VL_FV_CHECKBOX type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_CHECKBOX' ##NO_TEXT.
  constants GC_VL_FV_BSTAT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_BSTAT' ##NO_TEXT.
  constants GC_VL_FV_BOOLEAN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_BOOLEAN' ##NO_TEXT.
  constants GC_VL_FV_BOOLE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_BOOLE' ##NO_TEXT.
  constants GC_VL_FV_BDM_PROMISE_STATE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_BDM_PROMISE_STATE' ##NO_TEXT.
  constants GC_VL_FV_AS4FLAG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_AS4FLAG' ##NO_TEXT.
  constants GC_VL_FV_ANWND_EBKO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_ANWND_EBKO' ##NO_TEXT.
  constants GC_VL_CT_TTYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TTYP' ##NO_TEXT.
  constants GC_VL_CT_TSTC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TSTC' ##NO_TEXT.
  constants GC_VL_CT_TMABC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TMABC' ##NO_TEXT.
  constants GC_VL_CT_TFKB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TFKB' ##NO_TEXT.
  constants GC_VL_CT_TCURV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TCURV' ##NO_TEXT.
  constants GC_VL_CT_TCURC type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TCURC' ##NO_TEXT.
  constants GC_VL_CT_TBDLS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TBDLS' ##NO_TEXT.
  constants GC_VL_CT_TB004 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_TB004' ##NO_TEXT.
  constants GC_VL_CT_T683 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T683' ##NO_TEXT.
  constants GC_VL_CT_T2538 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T2538' ##NO_TEXT.
  constants GC_VL_CT_T2513 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T2513' ##NO_TEXT.
  constants GC_VL_CT_T2248 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T2248' ##NO_TEXT.
  constants GC_VL_CT_T2247 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T2247' ##NO_TEXT.
  constants GC_VL_CT_T059P type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T059P' ##NO_TEXT.
  constants GC_VL_CT_T054 type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T054' ##NO_TEXT.
  constants GC_VL_CT_T053R type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T053R' ##NO_TEXT.
  constants GC_VL_CT_T042F type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T042F' ##NO_TEXT.
  constants GC_VL_CT_T028V type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_CT_T028V' ##NO_TEXT.
  constants GC_VL_FV_RANTYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_RANTYP' ##NO_TEXT.
  constants GC_VL_FV_PFORM type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_PFORM' ##NO_TEXT.
  constants GC_VL_FV_MWART type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_MWART' ##NO_TEXT.
  constants GC_VL_FV_MITKZ type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_MITKZ' ##NO_TEXT.
  constants GC_VL_FV_KOART_AV type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_KOART_AV' ##NO_TEXT.
  constants GC_VL_FV_KOART type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_KOART' ##NO_TEXT.
  constants GC_VL_FV_INTTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_INTTYPE' ##NO_TEXT.
  constants GC_VL_FV_INTAG_EB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_INTAG_EB' ##NO_TEXT.
  constants GC_VL_FV_HWMET type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_HWMET' ##NO_TEXT.
  constants GC_VL_FV_GLACCOUNT_TYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_GLACCOUNT_TYPE' ##NO_TEXT.
  constants GC_VL_FV_FLAG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FLAG' ##NO_TEXT.
  constants GC_VL_FV_FIS_TMPL_ACC_POLICY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FIS_TMPL_ACC_POLICY' ##NO_TEXT.
  constants GC_VL_FV_FEB_PART_APPL_STATUS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FEB_PART_APPL_STATUS' ##NO_TEXT.
  constants GC_VL_FV_FEB_N2PCHGIND type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FEB_N2PCHGIND' ##NO_TEXT.
  constants GC_VL_FV_FEB_ML_STATUS_AD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FEB_ML_STATUS_AD' ##NO_TEXT.
  constants GC_VL_FV_FEB_ML_STATUS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FEB_ML_STATUS' ##NO_TEXT.
  constants GC_VL_FV_FEB_ADV_ASSIGNMENT_RE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FEB_ADV_ASSIGNMENT_REP_STATUS' ##NO_TEXT.
  constants GC_VL_FV_FDC_XCPDD_MODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_XCPDD_MODE' ##NO_TEXT.
  constants GC_VL_FV_FDC_DATA_ENTRY_STATUS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_DATA_ENTRY_STATUS_CODE' ##NO_TEXT.
  constants GC_VL_FV_FDC_APPROVAL_STATUS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_APPROVAL_STATUS' ##NO_TEXT.
  constants GC_VL_FV_FDC_APPLICATION_ID type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_APPLICATION_ID' ##NO_TEXT.
  constants GC_VL_FV_FDC_ACCDOC_TMP_DOC_TY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_ACCDOC_TMP_DOC_TYPE' ##NO_TEXT.
  constants GC_VL_FV_FDC_ACCDOC_ITM_COPA_V type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_ACCDOC_ITM_COPA_VERSION' ##NO_TEXT.
  constants GC_VL_FV_FDC_ACCDOC_ITM_ACTION type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_ACCDOC_ITM_ACTION_CODE' ##NO_TEXT.
  constants GC_VL_FV_FDC_ACCDOC_HDR_ACTION type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FDC_ACCDOC_HDR_ACTION_CODE' ##NO_TEXT.
  constants GC_VL_FV_FCLM_BAM_CONTRACT_TYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FCLM_BAM_CONTRACT_TYPE' ##NO_TEXT.
  constants GC_VL_FV_FAR_PSTRL_APPLICATION type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FAR_PSTRL_APPLICATION_TYPE' ##NO_TEXT.
  constants GC_VL_FV_FARP_MAHNS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FARP_MAHNS' ##NO_TEXT.
  constants GC_VL_FV_FARP_LB_ITM_LIFECYC_S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FARP_LB_ITM_LIFECYC_STAT' ##NO_TEXT.
  constants GC_VL_FV_FARP_KOART type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FARP_KOART' ##NO_TEXT.
  constants GC_VL_FV_FARP_CL_LINE_ITEM_TYP type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FARP_CL_LINE_ITEM_TYPE' ##NO_TEXT.
  constants GC_VL_FV_FARP_BS_ITM_LIFECYC_S type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FARP_BS_ITM_LIFECYC_STAT' ##NO_TEXT.
  constants GC_VL_FV_FARP_BOOLEAN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FARP_BOOLEAN' ##NO_TEXT.
  constants GC_VL_FV_FARP_ASTAT_EB_SL type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FARP_ASTAT_EB_SL' ##NO_TEXT.
  constants GC_VL_FV_FAC_RJET_WEEK_DAY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'VL_FV_FAC_RJET_WEEK_DAY' ##NO_TEXT.

  methods GET_EXTENDED_MODEL
  final
    exporting
      !EV_EXTENDED_SERVICE type /IWBEP/MED_GRP_TECHNICAL_NAME
      !EV_EXT_SERVICE_VERSION type /IWBEP/MED_GRP_VERSION
      !EV_EXTENDED_MODEL type /IWBEP/MED_MDL_TECHNICAL_NAME
      !EV_EXT_MODEL_VERSION type /IWBEP/MED_MDL_VERSION
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods LOAD_TEXT_ELEMENTS
  final
    returning
      value(RT_TEXT_ELEMENTS) type TT_TEXT_ELEMENTS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFAC_FINANCIALS_PO_MPC IMPLEMENTATION.


  method DEFINE.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*


data:
  lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ, "#EC NEEDED
  lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type, "#EC NEEDED
  lo_property       type ref to /iwbep/if_mgw_odata_property, "#EC NEEDED
  lo_association    type ref to /iwbep/if_mgw_odata_assoc,  "#EC NEEDED
  lo_assoc_set      type ref to /iwbep/if_mgw_odata_assoc_set, "#EC NEEDED
  lo_ref_constraint type ref to /iwbep/if_mgw_odata_ref_constr, "#EC NEEDED
  lo_nav_property   type ref to /iwbep/if_mgw_odata_nav_prop, "#EC NEEDED
  lo_action         type ref to /iwbep/if_mgw_odata_action, "#EC NEEDED
  lo_parameter      type ref to /iwbep/if_mgw_odata_property, "#EC NEEDED
  lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set, "#EC NEEDED
  lo_complex_prop   type ref to /iwbep/if_mgw_odata_cmplx_prop. "#EC NEEDED

* Extend the model
model->extend_model( iv_model_name = 'FAC_FINANCIALS_POSTING_MDL' iv_model_version = '0001' ). "#EC NOTEXT

model->set_schema_namespace( 'FAC_FINANCIALS_POSTING_SRV' ).


*
* Disable all the complex types that were disabled from reference model
*
* Disable complex type 'APARAccountKey'
try.
lo_complex_type = model->get_complex_type( iv_cplx_type_name = 'APARAccountKey' ). "#EC NOTEXT
lo_complex_type->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.

if lo_complex_type is bound.
* Disable all the properties for this complex type
try.
lo_property = lo_complex_type->get_property( iv_property_name = 'CompanyCode' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_complex_type->get_property( iv_property_name = 'FinancialAccountType' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_complex_type->get_property( iv_property_name = 'APARAccount' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
endif.


*
* Disable all the entity types that were disabled from reference model
*
* Disable entity type 'SAP__Currency'
try.
lo_entity_type = model->get_entity_type( iv_entity_name = 'SAP__Currency' ). "#EC NOTEXT
lo_entity_type->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.

IF lo_entity_type IS BOUND.
* Disable all the properties for this entity type
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'CurrencyCode' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'ISOCode' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'Text' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'DecimalPlaces' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.


endif.

* Disable entity type 'SAP__UnitOfMeasure'
try.
lo_entity_type = model->get_entity_type( iv_entity_name = 'SAP__UnitOfMeasure' ). "#EC NOTEXT
lo_entity_type->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.

IF lo_entity_type IS BOUND.
* Disable all the properties for this entity type
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'UnitCode' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'ISOCode' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'ExternalCode' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'Text' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_property = lo_entity_type->get_property( iv_property_name = 'DecimalPlaces' ). "#EC NOTEXT
lo_property->set_disabled( iv_disabled = abap_true ).
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.


endif.


*
*Disable all the entity sets that were disabled from reference model
*
try.
lo_entity_set = model->get_entity_set( iv_entity_set_name = 'SAP__Currencies' ). "#EC NOTEXT
IF lo_entity_set IS BOUND.
lo_entity_set->set_disabled( iv_disabled = abap_true ).
ENDIF.
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
try.
lo_entity_set = model->get_entity_set( iv_entity_set_name = 'SAP__UnitsOfMeasure' ). "#EC NOTEXT
IF lo_entity_set IS BOUND.
lo_entity_set->set_disabled( iv_disabled = abap_true ).
ENDIF.
CATCH /iwbep/cx_mgw_med_exception.
*  No Action was taken as the OData Element is not a part of redefined service
ENDTRY.
  endmethod.


  method GET_EXTENDED_MODEL.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*



ev_extended_service  = 'FAC_FINANCIALS_POSTING_SRV'.                "#EC NOTEXT
ev_ext_service_version = '0001'.               "#EC NOTEXT
ev_extended_model    = 'FAC_FINANCIALS_POSTING_MDL'.                    "#EC NOTEXT
ev_ext_model_version = '0001'.                   "#EC NOTEXT
  endmethod.


  method GET_LAST_MODIFIED.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  constants: lc_gen_date_time type timestamp value '20230411145009'. "#EC NOTEXT
rv_last_modified = super->get_last_modified( ).
IF rv_last_modified LT lc_gen_date_time.
  rv_last_modified = lc_gen_date_time.
ENDIF.
  endmethod.


  method LOAD_TEXT_ELEMENTS.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*


data:
  lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ,           "#EC NEEDED
  lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,           "#EC NEEDED
  lo_property       type ref to /iwbep/if_mgw_odata_property,             "#EC NEEDED
  lo_association    type ref to /iwbep/if_mgw_odata_assoc,                "#EC NEEDED
  lo_assoc_set      type ref to /iwbep/if_mgw_odata_assoc_set,            "#EC NEEDED
  lo_ref_constraint type ref to /iwbep/if_mgw_odata_ref_constr,           "#EC NEEDED
  lo_nav_property   type ref to /iwbep/if_mgw_odata_nav_prop,             "#EC NEEDED
  lo_action         type ref to /iwbep/if_mgw_odata_action,               "#EC NEEDED
  lo_parameter      type ref to /iwbep/if_mgw_odata_property,             "#EC NEEDED
  lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set.           "#EC NEEDED


DATA:
     ls_text_element TYPE ts_text_element.                   "#EC NEEDED
  endmethod.
ENDCLASS.
