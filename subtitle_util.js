/**
 * Created by qiaoxueshi on 6/27/15.
 */

module.exports = {
    webvttLinesToSrtLines: function(webvttLines) {
        //match time line, such as: 00:00:29.586 --> 00:00:30.106 A:middle
        var timeLineRegex = /^([0-9:.]+)\.(\d+ --> [0-9:.]+)\.(\d+)/;
        var statements = [];
        var statement = {};
        webvttLines.forEach(function(line) {
            if (line.trim().length != 0) {
                var groups = line.match(timeLineRegex);
                if (groups) {
                    if (statement.timeLine) {
                        statements.push(statement);
                        statement = {};
                    }
                    statement.timeLine = groups[1] + "," + groups[2] + "," + groups[3];
                } else {
                    line = line.replace(/&gt;/g, ">").replace(/&lt;/g, "<").replace(/&amp;/g, "&");
                    if (statement.subtitles) {
                        statement.subtitles.push(line);
                    } else {
                        statement.subtitles = [line];
                    }
                }
            }
        });
        if (statement.timeLine) {
            statements.push(statement);
        }

        statements = statements.filter(function (line, index, lines) {
           if (index > 0 && line.timeLine === lines[index - 1].timeLine) {
               return false;
           } else {
               return true;
           }
        });

        var finalLines = [];
        statements.forEach(function (srtLine, index) {
            finalLines.push(index + 1);
            finalLines.push(srtLine.timeLine);
            srtLine.subtitles.forEach(function (subtitle) {
                finalLines.push(subtitle)
            });
            finalLines.push("\n");
        });
        return finalLines;
    }
};