from fastapi import FastAPI
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd

# Load your pipeline
pipeline = joblib.load("decision_tree_pipeline.pkl")

app = FastAPI(
    title="Launch Price Prediction API",
    description="Predicts launch price based on raw input values using a Decision Tree pipeline."
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Input schema (raw values)
class LaunchData(BaseModel):
    Year: int = Field(..., ge=1950, le=2100, description="Year of launch")
    Organisation: str = Field(..., description="Organisation name (e.g., SpaceX, NASA)")
    Rocket_Status: str = Field(..., description="Status of rocket (e.g., Active, Retired)")
    Mission_Status: str = Field(..., description="Mission outcome (e.g., Success, Failure)")
    Country: str = Field(..., description="Country name (e.g., USA, Russia, China)")

@app.post("/predict")
def predict(data: LaunchData):
    # Convert input to DataFrame
    input_df = pd.DataFrame([data.dict()])
    prediction = pipeline.predict(input_df)
    return {"predicted_price_million_usd": float(prediction[0])}

@app.get("/")
def home():
    return {"message": "Welcome to the Launch Price Prediction API! Visit /docs for Swagger UI."}
