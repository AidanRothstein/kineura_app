exports.handler = async (event) => {
    for (const record of event.Records) {
        const bucket = record.s3.bucket.name;
        const key = record.s3.object.key;
        
        // Only process EMG data files
        if (key.startsWith('emg-data/')) {
            console.log(`Processing EMG file: ${key}`);
            
            // Convert to Parquet, extract metadata, update DynamoDB
            await processEMGFile(bucket, key);
        }
    }
};