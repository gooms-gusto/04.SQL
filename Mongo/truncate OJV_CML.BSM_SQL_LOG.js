truncate OJV_CML.BSM_SQL_LOG

db.OJV_CML.BSM_SQL_LOG.remove({});


db.OJV_CML.BSM_ACTIVITY_LOG.find().limit(1)


 db.getCollection('OJV_CML.BSM_ACTIVITY_LOG').find({"addTime":{$gte:6, $lte:8},"year":{$gte:2017,$lte:2018}}) 
 
 db.OJV_CML.BSM_ACTIVITY_LOG.find({
    addTime: {
        $gt: ISODate("2021-01-21T00:00:00.000Z"),
        $lt: ISODate("2021-11-24T00:00:00.000Z")
    }
})