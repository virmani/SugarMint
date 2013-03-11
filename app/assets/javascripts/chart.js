$(document).ready(function () {

  var bgChart;

  var options = {
    chart: {
      borderRadius: 0,
      zoomType: '',
      alignTicks: false,
      events: {
        selection: function (event) {
          if (event.xAxis) {
            onSelected(event.xAxis[0].min, event.xAxis[0].max);
          } else {
            alert("blah");
          }
        }
      }
    },
    plotOptions: {
      line: {
        marker: {
          enabled: true
        }
      },
      column: {
        pointWidth: 3,
        enableMouseTracking: true
      },
      series: {
        cropThreshold: 1000000,
        turboThreshold: 1000000,
        stickyTracking: true,
        allowPointSelect: true,
        marker: {
          enabled: true
        },
        cursor: ''
      },
      dataGrouping: {
        enabled: false
      }
    },
    rangeSelector: {
      selected: 2,
      buttons: [
        {
          type: 'day',
          count: 1,
          text: '1d'
        },
        {
          type: 'day',
          count: 3,
          text: '3d'
        },
        {
          type: 'week',
          count: 1,
          text: '1w'
        },
        {
          type: 'month',
          count: 1,
          text: '1m'
        },
        {
          type: 'month',
          count: 3,
          text: '3m'
        },
        {
          type: 'year',
          count: 1,
          text: '1y'
        },
        {
          type: 'all',
          text: 'All'
        }
      ]
    },
    xAxis: {
      timestamps: [],
      maxZoom: 14 * 3600000, //14 hours
      plotLines: []
    },
    tooltip: {
      crosshairs: [
        {
          width: 2
        },
        {
          width: 2
        }
      ],
      shared: true,
      formatter: function () {
        var s = '<b>' + Highcharts.dateFormat('%A, %b %e, %Y </b><br/><b>%l:%M:%S %p', this.x) + '</b>';

        if (this.points) {
          $.each(this.points, function (i, point) {
            s += '<br/>' + point.series.name + ' = ' + point.y;
          });
        } else {
          s += '<br/>' + this.point.text + '<br/>' + '<img src="' + this.point.imge_url + '"/>';
        }
        return s;
      }
    },

    series: []
  };

  var bgOptions = {
    chart: {
      renderTo: 'bgGraph'
    },
    yAxis: [
      {
        title: {
          text: 'mg/dl'
        },
        lineWidth: 2,
        plotBands: [
          {
            from: 0,
            to: 75,
            color: '#FF6600'
          },
          {
            from: 75,
            to: 170,
            color: '#00CC99'
          },
          {
            from: 170,
            to: 1000,
            color: '#FF6699'
          }
        ]
      }
    ]
  };
  bgOptions = jQuery.extend(true, {}, options, bgOptions);

  var bgseries = {
    name: 'BG',
    id: 'BG',
    data: [],
    type: 'line',
    yAxis: 0
  };

  var foursquareSeries = {
    name: 'Foursquare',
    data: [],
    type: 'flags',
    yAxis: 0,
    onSeries: 'BG',
    shape: 'squarepin'
  };

  var done = 0;
  var urls = ['bg'];
  var results = {};

  var root_url = $("#server-url").attr("data-url");

  $(function () {
    $("#datepicker").datepicker();
  });

  $.each(urls, function (index) {
    $.getJSON(root_url + '/events/' + urls[index] + '.json', function (response) {
      results[index] = response;
      ++done;

      if (done == urls.length) {
        bgseries.data = results[0];
        bgOptions.series = [bgseries];
      }
    });
  });

  $.getJSON(root_url + '/events/foursquare.json', function (response) {
    seriesData = new Array(response.length);
    for (var i = 0; i < response.length; i++) {
      dataPoint = {};
      dataPoint["x"] = response[i]["occured_at"];
      dataPoint["title"] = response[i]["source_name"];
      dataPoint["text"] = response[i]["short_summary"];
      seriesData[i] = dataPoint;
    }

    foursquareSeries.data = seriesData;
    bgOptions.series.push(foursquareSeries)
    bgChart = new Highcharts.StockChart(bgOptions);
  });
});

