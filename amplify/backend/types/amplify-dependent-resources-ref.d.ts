export type AmplifyDependentResourcesAttributes = {
  "api": {
    "kineuraapp": {
      "GraphQLAPIEndpointOutput": "string",
      "GraphQLAPIIdOutput": "string"
    }
  },
  "auth": {
    "kineuraapp5632dea0": {
      "AppClientID": "string",
      "AppClientIDWeb": "string",
      "IdentityPoolId": "string",
      "IdentityPoolName": "string",
      "UserPoolArn": "string",
      "UserPoolId": "string",
      "UserPoolName": "string"
    }
  },
  "custom": {
    "kinesisFirehose": {
      "FirehoseDeliveryStreamName": "string",
      "KinesisStreamArn": "string",
      "KinesisStreamName": "string"
    }
  },
  "function": {
    "S3Triggere50cdd9b": {
      "Arn": "string",
      "LambdaExecutionRole": "string",
      "LambdaExecutionRoleArn": "string",
      "Name": "string",
      "Region": "string"
    },
    "emgDataProcessor": {
      "Arn": "string",
      "LambdaExecutionRole": "string",
      "LambdaExecutionRoleArn": "string",
      "Name": "string",
      "Region": "string"
    }
  },
  "storage": {
    "EMGDataLake": {
      "BucketName": "string",
      "Region": "string"
    },
    "obama": {
      "Arn": "string",
      "Name": "string",
      "PartitionKeyName": "string",
      "PartitionKeyType": "string",
      "Region": "string",
      "StreamArn": "string"
    }
  }
}