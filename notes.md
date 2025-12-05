Make a model definition:

```
{
  "class": "dev.langchain4j.model.openai.OpenAiEmbeddingModel",
  "name": "my-cool-model",
  "params": {
    "baseUrl": "<UIT approved openai compatible endpoint>",
    "apiKey": "<APIKEY>",
    "modelName": "sentence-transformers/all-mpnet-base-v2",
    "timeout": 60,
    "logRequests": true,
    "logResponses": true,
    "maxRetries": 2
  }
}
```

Send it to Solr:
```
curl -XPUT 'http://localhost:8983/solr/blacklight-core/schema/text-to-vector-model-store' \
  --data-binary "@filename.json" \
  -H 'Content-type:application/json'
```
