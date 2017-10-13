//Todos los Eventos que escuchamos de Ableton

void oscEvent(OscMessage theOscMessage) {
  String path=theOscMessage.addrPattern();

  //Nos da la info de todos los clips que hay (track, clip, name, color) 
  if (path.equals("/live/name/clip")) {
    println("+++++++++++++Oyendo "+path+"++++++++++++++++");
    timerPuntoRojo.start(1);
    statePuntoRojo = 1;

    HashMap<String, Object> infoLoop = new HashMap<String, Object>();
    infoLoop.put("trackLoop", theOscMessage.arguments()[0]);
    infoLoop.put("clipLoop", theOscMessage.arguments()[1]);
    infoLoop.put("nombreLoop", theOscMessage.arguments()[2]);
    infoLoop.put("colorS", random(60, 100));
    infoLoop.put("colorB", random(80, 100));
    
    int track = (Integer)theOscMessage.arguments()[0];
    int clip = (Integer)theOscMessage.arguments()[1];
    if ((track == 1 && clip == 0) || (track == 3 && clip == 0) || (track == 5 && clip == 0) || (track == 5 && clip == 1)) {
      infoLoop.put("colorH", 13);
      infoLoop.put("colorS", 64);
      infoLoop.put("colorB", 95);
    } else if ((track == 1 && clip == 1) || (track == 3 && clip == 1)) {
      infoLoop.put("colorH", 358);
      infoLoop.put("colorS", 67);
      infoLoop.put("colorB", 93);
    } else if ((track == 1 && clip == 2) || (track == 3 && clip == 2) || (track == 5 && clip == 2)) {
      infoLoop.put("colorH", 112);
      infoLoop.put("colorS", 40);
      infoLoop.put("colorB", 69);
    } else if ((track == 2 && clip == 0) || (track == 4 && clip == 0) || (track == 6 && clip == 0)) {
      infoLoop.put("colorH", 50);
      infoLoop.put("colorS", 57);
      infoLoop.put("colorB", 99);
    } else if ((track == 2 && clip == 1) || (track == 4 && clip == 1) || (track == 4 && clip == 2) || (track == 6 && clip == 1)) {
      infoLoop.put("colorH", 198);
      infoLoop.put("colorS", 58);
      infoLoop.put("colorB", 82);
    } else if ((track == 2 && clip == 2) || (track == 6 && clip == 2)) {
      infoLoop.put("colorH", 280);
      infoLoop.put("colorS", 20);
      infoLoop.put("colorB", 80);
    }

    miAntropoloops.put(infoLoop.get("trackLoop")+"-"+infoLoop.get("clipLoop"), infoLoop); 
    println(infoLoop.get("trackLoop")+"-"+infoLoop.get("clipLoop"), "/", infoLoop);
    //infoLoop.get("nombreLoop")

    loopsIndexed.add(infoLoop.get("trackLoop")+"-"+infoLoop.get("clipLoop"));
    //println(loopsIndexed);

    PImage unaImagen = loadImage("../0_covers/"+(String)infoLoop.get("nombreLoop")+".jpg");

    misImagenes.put(infoLoop.get("trackLoop")+"-"+infoLoop.get("clipLoop"), unaImagen);
  }
  
  // Me avisa cuando live/name/clip ha terminado de lanzar mensajes
  // Es un path que he añadido yo a LiveOSC
  if (path.equals("/live/name/clip/done")) {
   println("***********DONE************");
   //println(theOscMessage.arguments()[0]);
  }

  //Aquí escuchamos si un clip cambia de estado (no clip (0), has clip (1), playing (2), triggered (3))
  if (path.equals("/live/clip/info")) {
    int claveTrack = theOscMessage.get(0).intValue();
    int claveClip = theOscMessage.get(1).intValue();
    int state = (Integer)theOscMessage.get(2).intValue();
    println(claveTrack+"-"+claveClip+": "+state);
    
    miAntropoloops.get(claveTrack+"-"+claveClip).put("state", state);

    if (state == 2) {
      ultimoLoop = miAntropoloops.get(claveTrack+"-"+claveClip);
      println(ultimoLoop);
      timerOnda.start(5);
      dibujaOnda = true;
      ultLoopParado = false;
        
     float dvolu = (Float)ultimoLoop.get("volume")*100;
      if (dvolu<=40) {
        d = dvolu*3/4;
      } 
      else if (40<dvolu && dvolu<=70) {
        d = (4*dvolu-70)/3;
      }
      else if (dvolu>70 && dvolu<=80) {
        d= 5*dvolu-280;
      }else if(dvolu > 80){
      d = 120;
      }
      
      
     }
      if (state == 1) {
        if((Integer)ultimoLoop.get("trackLoop")==claveTrack && (Integer)ultimoLoop.get("clipLoop")==claveClip){
        ultLoopParado = true;
        }
      }
  }

  if (path.equals("/live/play")) {
    playStop = theOscMessage.get(0).intValue();
  }

  if (path.equals("/live/clip/loopend")) {
    timerPuntoVerde.start(1);
    statePuntoVerde = 1;

    ct1 = ct1 + 1;
    String idTrackClip=loopsIndexed.get(ct1);
    miAntropoloops.get(idTrackClip).put("loopend", theOscMessage.get(0).floatValue());
    //println("loopend "+theOscMessage.get(0).floatValue());
  }

  if (path.equals("/live/volume")) {
    for (int i=0; i<loopsIndexed.size(); i++) {
      String claveClip=loopsIndexed.get(i);
      int[] a = int(split(claveClip, '-'));
      if (a[0] == theOscMessage.get(0).intValue()) {
        miAntropoloops.get(claveClip).put("volume", theOscMessage.get(1).floatValue());
        //println("volume "+theOscMessage.get(0).intValue()+" "+theOscMessage.get(1).floatValue());
       }
    }
  }

  if (path.equals("/live/solo")) {
    for (int i=0; i < loopsIndexed.size(); i++) {
      String claveClip=loopsIndexed.get(i);
      int[] a = int(split(claveClip, '-'));
      if (a[0] == theOscMessage.get(0).intValue()) {
        miAntropoloops.get(claveClip).put("solo", theOscMessage.get(1).intValue());
      }
    }
  }

  if (path.equals("/live/mute")) {
    for (int i=0; i < loopsIndexed.size(); i++) {
      String claveClip=loopsIndexed.get(i);
      int[] a = int(split(claveClip, '-'));
      if (a[0] == theOscMessage.get(0).intValue()) {
        miAntropoloops.get(claveClip).put("mute", theOscMessage.get(1).intValue());
        //println("mute "+theOscMessage.get(1).intValue());
      }
    }
  }

  if (path.equals("/live/tempo")) {
    timerPuntoVerde.start(1);
    statePuntoVerde = 1;

    tempo = theOscMessage.get(0).floatValue();
    println("tempo: OK");
  }
}