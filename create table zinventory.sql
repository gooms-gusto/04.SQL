/*
 Navicat Premium Data Transfer

 Source Server         : cmlprod
 Source Server Type    : MySQL
 Source Server Version : 50730
 Source Host           : localhost:63306
 Source Schema         : wms_cml

 Target Server Type    : MySQL
 Target Server Version : 50730
 File Encoding         : 65001

 Date: 02/11/2024 17:54:43
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for Z_InventoryBalance
-- ----------------------------
DROP TABLE IF EXISTS `Z_InventoryBalance`;
CREATE TABLE `Z_InventoryBalance`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `organizationId` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `customerId` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `warehouseId` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `locationId` varchar(60) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `traceId` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `muid` varchar(30) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '*',
  `lotNum` varchar(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `sku` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `qtyonHand` decimal(18, 8) NULL DEFAULT NULL,
  `packkey` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `UOM` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `qtyallocated` decimal(18, 8) NULL DEFAULT NULL,
  `qtyonHold` decimal(18, 8) NULL DEFAULT NULL,
  `qtyavailable` decimal(18, 8) NULL DEFAULT NULL,
  `qtyPicked` decimal(18, 8) NULL DEFAULT NULL,
  `SKUDesc` varchar(550) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `StockDate` date NULL DEFAULT NULL,
  `cube` decimal(18, 8) NULL DEFAULT NULL,
  `totalCube` decimal(24, 8) NULL DEFAULT NULL,
  `grossWeight` decimal(18, 8) NULL DEFAULT NULL,
  `netWeight` decimal(18, 8) NULL DEFAULT NULL,
  `freightClass` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `locationCategory` varchar(10) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `locGroup1` varchar(10) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `locGroup2` varchar(10) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `addWho` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `addTime` datetime NULL DEFAULT NULL,
  `editWho` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `editTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `I_Z_InventoryBalance_OWCTS`(`organizationId`, `warehouseId`, `customerId`, `traceId`, `StockDate`) USING BTREE,
  INDEX `idx_pedittime`(`addTime`, `editTime`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 149793390 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
