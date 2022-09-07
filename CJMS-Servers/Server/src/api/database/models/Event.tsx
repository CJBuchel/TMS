import mongoose from "mongoose";

export const EventSchema = new mongoose.Schema({
  event_name: {type: String, required: true},
  event_csv: {type: JSON, required: true},

  event_tables: [{type: String}],
  event_rounds: {type: Number, default: 3},
}, {
  capped: { size: 102400, max: 1, autoIndexId: true } // we only want one event document
});

export const EventModel = mongoose.model('Event', EventSchema);