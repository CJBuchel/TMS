import { ITeam } from "@cjms_shared/services";
import { Button } from "@mui/material";
import { Component } from "react";

interface IProps {
  external_teamData:ITeam[];
}

interface IState {}

export default class CloudPublish extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}

    this.handleCloudPublish = this.handleCloudPublish.bind(this);
  }



  handleCloudPublish() {
    if (confirm("Confirm Publish")) {
      console.log("Yep");
      // @todo
    }
  }

  render() {
    return (
      <>
        <Button
          variant="outlined"
          onClick={this.handleCloudPublish}
          sx={{
            // right: '0px',
            margin: '10px',
            marginRight: '10px',
            fontSize: '25px',
            float: 'right',
            borderColor: 'red',
            color: 'cyan'
          }}
        >Cloud Publish</Button>
      </>
    )
  }
}