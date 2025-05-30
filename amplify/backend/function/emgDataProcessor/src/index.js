const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

// Initialize AWS services
const dynamodb = new AWS.DynamoDB.DocumentClient();
const s3 = new AWS.S3();

// Get environment variables (these are set by CloudFormation)
const S3_BUCKET_NAME = process.env.S3_BUCKET_NAME;
const DYNAMODB_TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;
const GRAPHQL_ENDPOINT = process.env.GRAPHQL_ENDPOINT;

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    try {
        // Check if this is a GraphQL mutation from AppSync
        if (event.arguments && event.arguments.input) {
            return await processEMGBatch(event.arguments.input);
        }
        
        // Handle direct invocation or other event sources
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'EMG Data Processor Lambda function executed successfully',
                timestamp: new Date().toISOString()
            })
        };
        
    } catch (error) {
        console.error('Error processing event:', error);
        throw new Error(`Failed to process EMG data: ${error.message}`);
    }
};

async function processEMGBatch(input) {
    const { 
        sessionId, 
        userId, 
        batchSequence,
        batchStartTime,
        batchEndTime,
        samplingRate,
        dataPoints 
    } = input;

    // Validate input
    if (!sessionId || !userId || !dataPoints || dataPoints.length === 0) {
        throw new Error('Missing required fields: sessionId, userId, or dataPoints');
    }

    console.log(`Processing EMG batch for session ${sessionId}, sequence ${batchSequence}`);

    // Create optimized data structure for storage
    const optimizedBatch = {
        sessionId,
        userId,
        batchSequence,
        batchStartTime,
        batchEndTime,
        samplingRate,
        metadata: {
            dataPointCount: dataPoints.length,
            sensorIds: [...new Set(dataPoints.map(dp => dp.sensorId))],
            channelIds: [...new Set(dataPoints.map(dp => dp.channelId))],
            valueRange: {
                min: Math.min(...dataPoints.map(dp => dp.value)),
                max: Math.max(...dataPoints.map(dp => dp.value))
            },
            processedAt: new Date().toISOString()
        },
        // Store data in columnar format for better compression
        timestamps: dataPoints.map(dp => dp.timestamp),
        values: dataPoints.map(dp => dp.value),
        sensorIds: dataPoints.map(dp => dp.sensorId),
        channelIds: dataPoints.map(dp => dp.channelId)
    };

    // Store raw data in S3
    const s3Key = `emg-data/sessions/${userId}/${sessionId}/batch_${batchSequence}.json`;
    
    try {
        await s3.putObject({
            Bucket: S3_BUCKET_NAME,
            Key: s3Key,
            Body: JSON.stringify(optimizedBatch),
            ContentType: 'application/json',
            Metadata: {
                'session-id': sessionId,
                'user-id': userId,
                'batch-sequence': batchSequence.toString(),
                'data-points': dataPoints.length.toString()
            }
        }).promise();
        
        console.log(`Successfully stored batch data in S3: ${s3Key}`);
    } catch (error) {
        console.error('Error storing data in S3:', error);
        throw new Error(`Failed to store data in S3: ${error.message}`);
    }

    // Store metadata in DynamoDB
    const dynamoItem = {
        sessionId,
        batchSequence,
        userId,
        batchStartTime,
        batchEndTime,
        samplingRate,
        dataPointCount: dataPoints.length,
        processed: true,
        s3Key: s3Key,
        createdAt: new Date().toISOString(),
        // Store sample data points for quick access
        sampleDataPoints: [
            dataPoints[0], // First sample
            dataPoints[dataPoints.length - 1], // Last sample
            dataPoints.reduce((min, dp) => dp.value < min.value ? dp : min), // Min value sample
            dataPoints.reduce((max, dp) => dp.value > max.value ? dp : max)  // Max value sample
        ]
    };

    try {
        await dynamodb.put({
            TableName: DYNAMODB_TABLE_NAME,
            Item: dynamoItem
        }).promise();
        
        console.log('Successfully stored metadata in DynamoDB');
    } catch (error) {
        console.error('Error storing metadata in DynamoDB:', error);
        throw new Error(`Failed to store metadata: ${error.message}`);
    }

    // Update session statistics
    await updateSessionStats(sessionId, dataPoints.length);

    return {
        sessionId,
        batchSequence,
        status: 'SUCCESS',
        dataPointCount: dataPoints.length,
        s3Key: s3Key,
        processedAt: new Date().toISOString()
    };
}

async function updateSessionStats(sessionId, dataPointCount) {
    try {
        // Note: You'll need to create a separate table for sessions or use the same table with different keys
        await dynamodb.update({
            TableName: DYNAMODB_TABLE_NAME,
            Key: { sessionId },
            UpdateExpression: 'ADD totalBatches :one, totalDataPoints :count SET lastUpdated = :timestamp',
            ExpressionAttributeValues: {
                ':one': 1,
                ':count': dataPointCount,
                ':timestamp': new Date().toISOString()
            }
        }).promise();
        
        console.log(`Updated session ${sessionId} statistics`);
    } catch (error) {
        console.error('Error updating session stats:', error);
        // Don't throw - this is not critical for the main operation
    }
}
