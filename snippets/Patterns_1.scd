p = Pseries(0, 1, 100); // Patters define behavior -- similar to concept of a class
q = p.asStream;        // Streams execute patterns -- similar to concept of objects

10.do({ q.next; });

r = p.asStream;

15.do({ r.next.postln; });