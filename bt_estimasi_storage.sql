/*
 Navicat Premium Data Transfer

 Source Server         : DB PROD MIDDLEWARE
 Source Server Type    : MySQL
 Source Server Version : 80026
 Source Host           : 34.128.68.183:3306
 Source Schema         : prod_apibilling

 Target Server Type    : MySQL
 Target Server Version : 80026
 File Encoding         : 65001

 Date: 03/10/2023 16:31:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bt_estimasi_storage
-- ----------------------------
DROP TABLE IF EXISTS `bt_estimasi_storage`;
CREATE TABLE `bt_estimasi_storage`  (
  `idEstimasi` int NOT NULL AUTO_INCREMENT,
  `organtizationId` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `warehouseId` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `customerId` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `customerCode` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `salesOffice` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `rateBase` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `productCode` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `divisionNo` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `totalQty` decimal(30, 2) NULL DEFAULT NULL,
  `rate` decimal(30, 2) NULL DEFAULT NULL,
  `totalAmount` decimal(30, 2) NULL DEFAULT NULL,
  `addDate` datetime NULL DEFAULT NULL,
  `editTime` datetime NULL DEFAULT NULL,
  `addWho` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  PRIMARY KEY (`idEstimasi`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3472 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
