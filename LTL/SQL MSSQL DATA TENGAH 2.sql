USE dbcwd

select * from SQLMIDLTL_DEV.DEL_INTERFACE.dbo.vw_out_data_tab_linc where ORDER_NO='2180000176';
select * from SQLMIDLTL_DEV.DEL_INTERFACE.dbo.vw_out_data_line_tab_linc where MESSAGE_ID='3532';


select MAX(MESSAGE_ID) from SQLMIDLTL_DEV.DEL_INTERFACE.dbo.vw_in_data_tab_linc 
where CLASS_ID NOT IN('GR_PO_LOCAL')

select * from SQLMIDLTL_DEV.DEL_INTERFACE.dbo.vw_in_data_tab_linc ORDER BY MESSAGE_ID desc where  order_no  in ('2180000176');
select * from SQLMIDLTL_DEV.DEL_INTERFACE.dbo.vw_in_data_line_tab_linc  where  message_id  in ('3531') 

SELECT *  INTO vw_in_data_tab_linc FROM SQLMIDLTL_DEV.DEL_INTERFACE.dbo.vw_in_data_tab_linc WHERE 1=2

SELECT *  INTO vw_in_data_line_tab_linc FROM SQLMIDLTL_DEV.DEL_INTERFACE.dbo.vw_in_data_line_tab_linc WHERE 1=2

SELECT [CLASS_ID]
      ,[MESSAGE_ID]
      ,[COMPANY]
      ,[ORDER_NO]
      ,[RECEIVED_TIME]
      ,[TRANSFERRED_TIME]
      ,[SESSION_ID]
      ,[ROWVERSION]
      ,[ROWSTATE]
      ,[NOTES]
      ,[CUSTOMER_GROUP]
      ,[FLAG]
  FROM [SQLMIDLTL_DEV].[DEL_Interface].[dbo].[VW_OUT_DATA_TAB_LINC]
GO

