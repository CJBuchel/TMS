import React, {ChangeEvent, Component, InputHTMLAttributes, useState} from "react";
import Papa from "papaparse";

import "../../assets/Setup.scss"
import { callbackify } from "util";

interface IProps {}
interface IState {
  csv:any;
}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {
      csv:null
    }

    this.updateCSV = this.updateCSV.bind(this);
  }

  updateCSV(result:any) {
    this.setState({csv:result.data});
    console.log(result.data);
  }

  onScheduleImport(e:ChangeEvent<HTMLInputElement>) {
    e.preventDefault();
    const f:any = (e.target as HTMLInputElement).files?.[0];
    Papa.parse(f, {header:false, skipEmptyLines:true, complete:this.updateCSV});
  }

  handleSubmit() {
    
  }

  render() {
    return(
      <div className="setup-main">
        <div className="container">

          {/* Main Form */}
          <form>
            <h1>Schedule</h1>
            <input 
              type={"file"} 
              id={"scheduleImport"}
              accept={".csv"}
              onChange={(e:ChangeEvent<HTMLInputElement>) => this.onScheduleImport(e)}
            />
            or - <a href="https://firstaustralia.org/fll-scheduler/">Generate Schedule/CSV</a><br/>


            <h1>Event Name</h1>
            <input placeholder="event name..."/>
          </form>

        </div>
      </div>
    );
  }
}