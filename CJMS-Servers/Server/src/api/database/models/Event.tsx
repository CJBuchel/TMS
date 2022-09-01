import mongoose from "mongoose";

export const EventSchema = new mongoose.Schema({
  event_name: {type: String, required: true},
  event_csv: {type: JSON, required: true},
});

export const EventModel = mongoose.model('Event', EventSchema);