import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datatable-index-charts"
export default class extends Controller {
  connect() {
    var self = this

    $(".effective-datatable").on("draw.dt", function(e, dt, type, indexes) {
      var jsonCharts = dt.json.charts
      for (var chart in jsonCharts) {
        var chartkickChart = Chartkick.charts[chart]
        chartkickChart.redraw()
      }
    });
  }
}