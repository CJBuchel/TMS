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

    this.scrollCallback = this.scrollCallback.bind(this);
  }
  
  unmountScroll = false;

  scrollCallback() {
    if (this.unmountScroll) {
      return;
    } else {
      this.setState({scrollTop: this.newScroll(this.state.scrollTop)});
      window.requestAnimationFrame(() => this.scrollCallback());
    }
  }

  componentDidMount() {
    setTimeout(() => window.requestAnimationFrame(() => this.scrollCallback()), DEFAULT_DELAY);
  }

  componentWillUnmount() {
    this.unmountScroll = true;
    // this.setState({unmountScroll:true});
    // window.location.reload();
    // clearInterval();
  }

  bodyScrollHeight() {
    return this.state.scrollTop + (document.getElementById('table-body')?.scrollHeight || 0); // document.body.scrollHeight
  }
  
  isScrolling() {
    // console.log(document.getElementById('table-body')?.clientHeight);

    return ((document.getElementById('table-body')?.clientHeight || 0) < this.bodyScrollHeight());
  }

  newScroll(oldScroll:number) {
    const height = this.bodyScrollHeight();
    if (!this.isScrolling()) {
      // console.log("not scrolling");
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
    for (var i = 0; i < 50; i++) {
      content.push(
        <tr key={i}>
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
      <tbody id='table-body' style={{overflow: 'hidden'}}>
        {firstTable}
        {secondTable}
      </tbody>
    );
  }

  render() {
    return (
      <div className='table-wrapper ui segment' style={{direction: 'ltr', marginTop: -this.state.scrollTop}}>
        <table id='table-parent' className='fl-table ui scrollable single line very basic compact table'>
          <thead id='table-head'>
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