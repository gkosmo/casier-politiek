namespace :politicians do
  desc "Update party information for known Belgian politicians"
  task update_parties: :environment do
    # Manual mapping of Belgian politicians to their parties
    # This data is based on their primary party affiliation
    party_mappings = {
      # MR (Mouvement Réformateur) - Centre-right liberal
      "Daniel Bacquelaine" => "MR",
      "François Bellot" => "MR",
      "David Clarinval" => "MR",
      "Olivier Destrebecq" => "MR",
      "Valérie De Bue" => "MR",
      "François-Xavier de Donnea" => "MR",
      "Corinne De Permentier" => "MR",
      "Daniel Ducarme" => "MR",
      "Denis Ducarme" => "MR",
      "Jean-Jacques Flahaux" => "MR",
      "Jacqueline Galant" => "MR",
      "Olivier Hamal" => "MR",
      "Kattrin Jadin" => "MR",
      "Carine Lecomte" => "MR",
      "Marie-Christine Marghem" => "MR",

      # DéFI - Centre-left
      "François-Xavier de Donnea" => "DéFI",
      "Olivier Maingain" => "DéFI",

      # PS (Parti Socialiste) - Left
      "Marie Arena" => "PS",
      "Colette Burgeon" => "PS",
      "Guy Coëme" => "PS",
      "Jean Cornil" => "PS",
      "Valérie Déom" => "PS",
      "Camille Dieu" => "PS",
      "André Flahaut" => "PS",
      "André Frédéric" => "PS",
      "Thierry Giet" => "PS",
      "Karine Lalieux" => "PS",
      "Marie-Claire Lambert" => "PS",
      "Alain Mathot" => "PS",
      "Yvan Mayeur" => "PS",
      "Patrick Moriau" => "PS",
      "Linda Musin" => "PS",
      "André Perpète" => "PS",
      "Éric Thiébaut" => "PS",
      "Bruno Van Grootenbrulle" => "PS",

      # cdH (Centre Démocrate Humaniste) - Centre
      "Josy Arens" => "cdH",
      "Christian Brotcorne" => "cdH",
      "Georges Dallemagne" => "cdH",
      "Joseph George" => "cdH",
      "Catherine Fonck" => "cdH",
      "Clotilde Nyssens" => "cdH",
      "Isabelle Tasiaux-De Neys" => "cdH",
      "David Lavaux" => "cdH",
      "Marie-Martine Schyns" => "cdH",
      "Brigitte Wiaux" => "cdH",

      # Ecolo - Centre-left green
      "Juliette Boulet" => "Ecolo",
      "Zoé Genot" => "Ecolo",
      "Muriel Gerkens" => "Ecolo",
      "Georges Gilkinet" => "Ecolo",
      "Éric Jadot" => "Ecolo",
      "Fouad Lahssaini" => "Ecolo",
      "Thérèse Snoy" => "Ecolo",

      # CD&V (Christen-Democratisch en Vlaams) - Centre
      "Sonja Becq" => "CD&V",
      "Hendrik Bogaert" => "CD&V",
      "Ingrid Claes" => "CD&V",
      "Lieve Van Daele" => "CD&V",
      "Mia De Schamphelaere" => "CD&V",
      "Roel Deseyn" => "CD&V",
      "Leen Dierick" => "CD&V",
      "Michel Doomst" => "CD&V",
      "Luc Goutry" => "CD&V",
      "Gerald Kindermans" => "CD&V",
      "Nathalie Muylle" => "CD&V",
      "Katrien Partyka" => "CD&V",
      "Raf Terwingen" => "CD&V",
      "Ilse Uyttersprot" => "CD&V",
      "Jef Van den Bergh" => "CD&V",
      "Liesbeth Van der Auwera" => "CD&V",
      "Stefaan Vercamer" => "CD&V",
      "Mark Verhaegen" => "CD&V",
      "Servais Verherstraeten" => "CD&V",
      "Katrien Schryvers" => "CD&V",
      "Kristof Waterschoot" => "CD&V",
      "Hilâl Yalçin" => "CD&V",

      # Open VLD (Open Vlaamse Liberalen en Democraten) - Centre-right liberal
      "Yolande Avontroodt" => "Open VLD",
      "Rik Daems" => "Open VLD",
      "Maggie De Block" => "Open VLD",
      "Mathias De Clercq" => "Open VLD",
      "Herman De Croo" => "Open VLD",
      "Sofie Staelraeve" => "Open VLD",
      "Katia della Faille de Leverghem" => "Open VLD",
      "Patrick Dewael" => "Open VLD",
      "Sabien Lahaye-Battheu" => "Open VLD",
      "Willem-Frederik Schiltz" => "Open VLD",
      "Bart Somers" => "Open VLD",
      "Ine Somers" => "Open VLD",
      "Luk Van Biesen" => "Open VLD",
      "Ludo Van Campenhout" => "Open VLD",
      "Carina Van Cauter" => "Open VLD",
      "Hilde Vautmans" => "Open VLD",
      "Geert Versnick" => "Open VLD",
      "Xavier Baeselen" => "Open VLD",
      "Philippe Collard" => "Open VLD",
      "Luc Gustin" => "Open VLD",
      "Josée Lejeune" => "Open VLD",
      "Jacques Otlet" => "Open VLD",
      "Sophie Pécriaux" => "Open VLD",

      # Vlaams Belang - Far-right
      "Gerolf Annemans" => "Vlaams Belang",
      "Koen Bultinck" => "Vlaams Belang",

      # sp.a (Socialistische Partij Anders) - Left
      "Ronny Balcaen" => "sp.a",
      "Patrick Cocriamont" => "sp.a",
    }

    updated_count = 0
    not_found_count = 0

    party_mappings.each do |name, party|
      politician = Politician.find_by(name: name)
      if politician
        if politician.party == "Unknown" || politician.party.nil?
          politician.update!(party: party)
          puts "✓ Updated #{name} -> #{party}"
          updated_count += 1
        else
          puts "- #{name} already has party: #{politician.party}"
        end
      else
        puts "✗ Politician not found: #{name}"
        not_found_count += 1
      end
    end

    puts "\nSummary:"
    puts "  Updated: #{updated_count}"
    puts "  Not found: #{not_found_count}"
    puts "  Total in mappings: #{party_mappings.size}"
  end
end
