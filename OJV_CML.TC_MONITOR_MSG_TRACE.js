/*
 Navicat Premium Data Transfer

 Source Server         : Datahubmongo
 Source Server Type    : MongoDB
 Source Server Version : 30618 (3.6.18)
 Source Host           : 172.31.9.92:27017
 Source Schema         : datahubmongo

 Target Server Type    : MongoDB
 Target Server Version : 30618 (3.6.18)
 File Encoding         : 65001

 Date: 29/10/2022 22:41:39
*/


// ----------------------------
// Collection structure for OJV_CML.TC_MONITOR_MSG_TRACE
// ----------------------------
db.getCollection("OJV_CML.TC_MONITOR_MSG_TRACE").drop();
db.createCollection("OJV_CML.TC_MONITOR_MSG_TRACE");
db.getCollection("OJV_CML.TC_MONITOR_MSG_TRACE").createIndex({
    messageGroupSysId: NumberInt("-1")
}, {
    name: "ix_OJV_CML.TC_MONITOR_MSG_TRACE",
    background: true
});
