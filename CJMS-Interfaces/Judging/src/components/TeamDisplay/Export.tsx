import { ITeam } from "@cjms_shared/services";
import { ExportToCsv } from "export-to-csv-fix-source-map";

export default class Export {
  private _teams:ITeam[] = [];
  private _rounds:number = 0;

  constructor(teams:ITeam[], rounds:number) {
    this._teams = teams;
    this._rounds = rounds;
  }

  getFormattedData(comments:boolean) {
    var formatedData:any[] = [];
    this._teams.sort((a, b) => { return b.ranking - a.ranking}); // make sure it's in the correct order

    this._teams.map((team) => {
      var round_values:any = {};
      for (var i = 0; i < this._rounds; i++) {
        const score = team.scores[i]?.score || '';
        const gp = team.scores[i]?.score || '';
        const pub = team.scores[i]?.score || '';
        const priv = team.scores[i]?.score || '';

        if (comments) {
          const obj = {
            [`R${i+1} Score`]:score,
            [`R${i+1} GP`]:gp,
            [`R${i+1} Pub Comment`]:pub,
            [`R${i+1} Priv Comment`]:priv,
          }
  
          round_values = {...round_values, ...obj};
        } else {
          const obj = {
            [`R${i+1} Score`]:score,
            [`R${i+1} GP`]:gp
          }
  
          round_values = {...round_values, ...obj};
        }
      }

      formatedData.push({
        'Ranking':team.ranking,
        'Team Number':team.team_number,
        'Team Name':team.team_name,
        ...round_values
      });

    });

    console.log(formatedData);
    return formatedData;
  }

  exportCSV(comments:boolean = false) {
    const exporter = new ExportToCsv({
      fieldSeparator: ',',
      quoteStrings: '"',
      decimalSeparator: '.',
      showLabels: true, 
      showTitle: true,
      filename: 'cjms_export',
      title: 'cjms_export',
      useTextFile: false,
      useBom: true,
      useKeysAsHeaders: true,
    })

    // this.getFormattedData(comments);

    exporter.generateCsv(this.getFormattedData(comments));
  }
}