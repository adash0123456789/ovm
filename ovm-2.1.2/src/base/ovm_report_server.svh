// $Id: //dvt/vtech/dev/main/ovm/src/base/ovm_report_server.svh#21 $
//------------------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   Copyright 2007-2009 Cadence Design Systems, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

`ifndef OVM_REPORT_SERVER_SVH
`define OVM_REPORT_SERVER_SVH

typedef class ovm_report_object;

//------------------------------------------------------------------------------
//
// CLASS: ovm_report_server
//
// ovm_report_server is a global server that processes all of the reports
// generated by an ovm_report_handler. None of its methods are intended to be
// called by normal testbench code, although in some circumstances the virtual
// methods process_report and/or compose_ovm_info may be overloaded in a
// subclass.
//
//------------------------------------------------------------------------------

class ovm_report_server;

  local int max_quit_count; 
  local int quit_count;
  local int severity_count[ovm_severity];

  // Variable: id_count
  //
  // An associative array holding the number of occurences
  // for each unique report ID.

  protected int id_count[string];

  bit enable_report_id_count_summary=1;


  // Function: new
  //
  // Creates the central report server, if not already created. Else, does
  // nothing. The constructor is protected to enforce a singleton.

  function new();
    set_max_quit_count(0);
    reset_quit_count();
    reset_severity_counts();
  endfunction


  // Function: set_max_quit_count

  function void set_max_quit_count(int count);
    max_quit_count = count < 0 ? 0 : count;
  endfunction

  // Function: get_max_quit_count
  //
  // Get or set the maximum number of COUNT actions that can be tolerated
  // before an OVM_EXIT action is taken. The default is 0, which specifies
  // no maximum.

  function int get_max_quit_count();
    return max_quit_count;
  endfunction


  // Function: set_quit_count

  function void set_quit_count(int quit_count);
    quit_count = quit_count < 0 ? 0 : quit_count;
  endfunction

  // Function: get_quit_count

  function int get_quit_count();
    return quit_count;
  endfunction

  // Function: incr_quit_count

  function void incr_quit_count();
    quit_count++;
  endfunction

  // Function: reset_quit_count
  //
  // Set, get, increment, or reset to 0 the quit count, i.e., the number of
  // COUNT actions issued.

  function void reset_quit_count();
    quit_count = 0;
  endfunction

  // Function: is_quit_count_reached
  //
  // If is_quit_count_reached returns 1, then the quit counter has reached
  // the maximum.

  function bit is_quit_count_reached();
    return (quit_count >= max_quit_count);
  endfunction


  // Function: set_severity_count

  function void set_severity_count(ovm_severity severity, int count);
    severity_count[severity] = count < 0 ? 0 : count;
  endfunction

  // Function: get_severity_count

  function int get_severity_count(ovm_severity severity);
    return severity_count[severity];
  endfunction

  // Function: incr_severity_count

  function void incr_severity_count(ovm_severity severity);
    severity_count[severity]++;
  endfunction

  // Function: reset_severity_counts
  //
  // Set, get, or increment the counter for the given severity, or reset
  // all severity counters to 0.

  function void reset_severity_counts();
    ovm_severity_type s;
    s = s.first();
    forever begin
      severity_count[s] = 0;
      if(s == s.last()) break;
      s = s.next();
    end
  endfunction


  // Function: set_id_count

  function void set_id_count(string id, int count);
    id_count[id] = count < 0 ? 0 : count;
  endfunction

  // Function: get_id_count

  function int get_id_count(string id);
    if(id_count.exists(id))
      return id_count[id];
    return 0;
  endfunction

  // Function: incr_id_count
  //
  // Set, get, or increment the counter for reports with the given id.

  function void incr_id_count(string id);
    if(id_count.exists(id))
      id_count[id]++;
    else
      id_count[id] = 1;
  endfunction


  // f_display
  //
  // This method sends string severity to the command line if file is 0 and to
  // the file(s) specified by file if it is not 0.

  function void f_display(OVM_FILE file, string str);
    if (file == 0)
      $display(str);
    else
      $fdisplay(file, str);
  endfunction


  // Function- report
  //
  //

  extern virtual function void report(
      ovm_severity severity,
      string name,
      string id,
      string message,
      int verbosity_level,
      string filename,
      int line,
      ovm_report_object client
      );


  // Function: process_report
  //
  // Calls <compose_message> to construct the actual message to be
  // output. It then takes the appropriate action according to the value of
  // action and file. 
  //
  // This method can be overloaded by expert users to customize the way the
  // reporting system processes reports and the actions enabled for them.

  extern virtual function void process_report(
      ovm_severity severity,
      string name,
      string id,
      string message,
      ovm_action action,
      OVM_FILE file,
      string filename,
      int line,
      string composed_message,
      int verbosity_level,
      ovm_report_object client
      );


  // Function: compose_message
  //
  // Constructs the actual string sent to the file or command line
  // from the severity, component name, report id, and the message itself. 
  //
  // Expert users can overload this method to customize report formatting.

  extern virtual function string compose_message(
      ovm_severity severity,
      string name,
      string id,
      string message,
      string filename,
      int    line
      );


  // Function: summarize
  //
  // See ovm_report_object::report_summarize method.

  virtual function void summarize(OVM_FILE file=0);
    string id;
    string name;
    string output_str;

    f_display(file, "");
    f_display(file, "--- OVM Report Summary ---");
    f_display(file, "");

    if(max_quit_count != 0) begin
      if ( quit_count >= max_quit_count ) f_display(file, "Quit count reached!");
      $sformat(output_str, "Quit count : %d of %d",
                             quit_count, max_quit_count);
      f_display(file, output_str);
    end

    f_display(file, "** Report counts by severity");
    for(ovm_severity_type s = s.first(); 1; s = s.next()) begin
      if(severity_count.exists(s)) begin
        int cnt;
        cnt = severity_count[s];
        name = s.name();
        $sformat(output_str, "%s :%5d", name, cnt);
        f_display(file, output_str);
      end
      if(s == s.last()) break;
    end

    if (enable_report_id_count_summary) begin

      f_display(file, "** Report counts by id");
      for(int found = id_count.first(id);
           found;
           found = id_count.next(id)) begin
        int cnt;
        cnt = id_count[id];
        $sformat(output_str, "[%s] %5d", id, cnt);
        f_display(file, output_str);
      end

    end

  endfunction


  // Function: dump_server_state
  //
  // Dumps server state information.

  function void dump_server_state();

    string s;
    ovm_severity_type sev;
    string id;

    f_display(0, "report server state");
    f_display(0, "");   
    f_display(0, "+-------------+");
    f_display(0, "|   counts    |");
    f_display(0, "+-------------+");
    f_display(0, "");

    $sformat(s, "max quit count = %5d", max_quit_count);
    f_display(0, s);
    $sformat(s, "quit count = %5d", quit_count);
    f_display(0, s);

    sev = sev.first();
    forever begin
      int cnt;
      cnt = severity_count[sev];
      s = sev.name();
      $sformat(s, "%s :%5d", s, cnt);
      f_display(0, s);
      if(sev == sev.last())
        break;
      sev = sev.next();
    end

    if(id_count.first(id))
    do begin
      int cnt;
      cnt = id_count[id];
      $sformat(s, "%s :%5d", id, cnt);
      f_display(0, s);
    end
    while (id_count.next(id));

  endfunction


  // Function- copy_severity_counts
  //
  // Internal method.

  function void copy_severity_counts(ovm_report_server dst);
    foreach(severity_count[s]) begin
      dst.set_severity_count(s,severity_count[s]);
    end
  endfunction


  // Function- copy_severity_counts
  //
  // Internal method.

  function void copy_id_counts(ovm_report_server dst);
    foreach(id_count[s]) begin
      dst.set_id_count(s,id_count[s]);
    end
  endfunction


endclass


//----------------------------------------------------------------------
// CLASS- ovm_report_global_server
//
// Singleton object that maintains a single global report server
//----------------------------------------------------------------------
class ovm_report_global_server;

  static ovm_report_server global_report_server = null;

  function new();
    if (global_report_server == null)
      global_report_server = new;
  endfunction


  // Function: get_server
  //
  // Returns a handle to the central report server.

  function ovm_report_server get_server();
    return global_report_server;
  endfunction


  // Function- set_server
  //
  //

  function void set_server(ovm_report_server server);
    server.set_max_quit_count(global_report_server.get_max_quit_count());
    server.set_quit_count(global_report_server.get_quit_count());
    global_report_server.copy_severity_counts(server);
    global_report_server.copy_id_counts(server);
    global_report_server = server;
  endfunction

endclass

`endif // OVM_REPORT_SERVER_SVH
