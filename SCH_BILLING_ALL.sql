DELIMITER $$

DROP PROCEDURE IF EXISTS `zCML_akb_Execute_BillingSP`$$

CREATE DEFINER = 'wms_cml'@'%'
PROCEDURE zCML_akb_Execute_BillingSP()
ENDPROC:
BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId VARCHAR(20);
    DECLARE v_warehouseId VARCHAR(20);
    DECLARE v_customerId VARCHAR(30);
    DECLARE v_spName VARCHAR(20);
    DECLARE v_productNo VARCHAR(20);
   
    
    -- Variabel untuk mengontrol loop cursor
    DECLARE v_finished INTEGER DEFAULT 0;
    
    -- Variabel untuk lock tracking
    DECLARE v_lock_acquired INTEGER DEFAULT 0;
    DECLARE v_process_start TIMESTAMP DEFAULT NOW();
    DECLARE v_total_processed INTEGER DEFAULT 0;
    DECLARE v_lock_check INTEGER DEFAULT 0;
    
    -- Deklarasi cursor untuk tabel Z_BAS_CUSTOMER_CUSTBILLING
    DECLARE billing_cursor CURSOR FOR
   SELECT
  cb.organizationId,
  cb.warehouseId,
  cb.customerId,
  zbccd.spName,
  zbccd.lottable01 AS productNo
FROM Z_BAS_CUSTOMER_CUSTBILLING cb INNER JOIN  Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
ON cb.organizationId = zbccd.organizationId
AND cb.lotatt01=zbccd.idGroupSp 
WHERE cb.organizationId='OJV_CML' AND cb.customerId='PT.ABC' AND cb.active='Y'
ORDER BY productNo ASC;

    -- Handler untuk menangani kondisi NOT FOUND (akhir cursor)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    
    -- Handler untuk menangani ERROR - pastikan lock di-release
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback jika ada transaksi yang sedang berjalan
        ROLLBACK;
        
        -- Release lock jika sudah di-acquire
        IF v_lock_acquired = 1 THEN
            DO RELEASE_LOCK('billing_sp_process_lock');
        END IF;
        
        -- Re-throw error
        RESIGNAL;
    END;
    
    -- Cek apakah ada proses yang sedang berjalan
    SET v_lock_check = IS_USED_LOCK('billing_sp_process_lock');
    
    -- Jika lock sedang digunakan, langsung exit
    IF v_lock_check IS NOT NULL THEN 
        LEAVE ENDPROC;
    END IF;
    
    -- Coba acquire lock dengan timeout 0 (immediate)
    SET v_lock_acquired = GET_LOCK('billing_sp_process_lock', 0);
    
    -- Cek apakah lock berhasil diperoleh
    IF v_lock_acquired = 1 THEN
        -- Lock berhasil diperoleh, lanjutkan proses
        
        -- Mulai transaksi
        START TRANSACTION;
        
        -- Buka cursor
        OPEN billing_cursor;
        
        -- Loop untuk memproses setiap baris
        billing_loop: LOOP
            -- Ambil data dari cursor
            FETCH billing_cursor INTO 
                v_organizationId,
                v_warehouseId,
                v_customerId,
                v_spName,
                v_productNo;
            
            -- Keluar dari loop jika sudah mencapai akhir data
            IF v_finished = 1 THEN
                LEAVE billing_loop;
            END IF;
            
            -- Increment counter
            SET v_total_processed = v_total_processed + 1;
            
            -- =====================================================
            -- PROSES BILLING DI SINI
            -- =====================================================
            
            -- Contoh: Proses untuk customer aktif
            IF v_active = 'Y' THEN
              
              IF v_productNo = '1700000045' THEN
SELECT 'N';

END IF; -- END IF v_productNo


            END IF;
            

            
        END LOOP billing_loop;
        
        -- Tutup cursor
        CLOSE billing_cursor;
        
        -- Commit transaksi
        COMMIT;
        
        -- Release lock setelah selesai
        DO RELEASE_LOCK('billing_sp_process_lock');
    END IF;
    
END$$

DELIMITER ;