import React, { Component, useRef } from 'react'
import "../../assets/application.scss";
import "../../assets/InfiniteTable.scss";

const DEFAULT_SPEED = 1;
const DEFAULT_DELAY = 1000;

interface IProps {}

interface IState {
  scrollTop:number;
}

export default class InfiniteTable extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      scrollTop: 0
    }
  }
  

  scrollCallback() {
    this.setState({scrollTop: this.newScroll(this.state.scrollTop)});
    window.requestAnimationFrame(() => this.scrollCallback());
  }

  componentDidMount() {
    setTimeout(() => window.requestAnimationFrame(() => this.scrollCallback()), DEFAULT_DELAY);
  }

  isScrolling() {
    return (document.body.clientHeight < this.bodyScrollHeight());
  }

  bodyScrollHeight() {
    return this.state.scrollTop + document.body.scrollHeight; // document.body.scrollHeight
  }

  newScroll(oldScroll:number) {
    const height = this.bodyScrollHeight();

    if (!this.isScrolling()) {
      return 0;
    } else if (oldScroll >= height/2) {
      console.log("Resetting");
      return oldScroll - height/2;
    } else {
      return oldScroll + (DEFAULT_SPEED/2);
    }
  }

  getFormattedData() {
    const content:any[] = []
    for (var i = 0; i < 30; i++) {
      content.push(
        <tr>
          <td>{i}</td>
          <td>Yay</td>
          <td>Yay</td>
          <td>Yay</td>
          <td>Yay</td>
        </tr>
      );
    }


    return(
      content
    );
  }

  renderTable() {
    const firstTable = this.getFormattedData();
    const secondTable = this.getFormattedData();

    return(
      <tbody style={{overflow: 'hidden'}}>
        {firstTable}
        {secondTable}
      </tbody>
    );
  }

  render() {
    return (
      <div className='infinite-table ui segment' style={{direction: 'ltr', marginTop: -this.state.scrollTop}}>
        <table className='ui scrollable single line very basic compact table'>
          <thead className='headers'>
            <tr>
              <th>Rank</th>
              <th>Team Name</th>
              <th>Round 1</th>
              <th>Round 2</th>
              <th>Round 3</th>
            </tr>
          </thead>
          { this.renderTable() }
        </table>
      </div>
    );
  }
} 