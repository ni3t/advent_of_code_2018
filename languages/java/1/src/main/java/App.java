import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/*
 * This Java source file was generated by the Gradle 'init' task.
 */
public class App {

  public int getSolution() {
    try {
      String currentDirectory = System.getProperty("user.dir");
      String filePath = currentDirectory + "/languages/java/1/input.txt";
      Path path = Paths.get(filePath);
      Scanner scanner = new Scanner(path);

      int result = 0;

      while (scanner.hasNextLine()) {
        String line = scanner.nextLine();
        Pattern pattern = Pattern.compile("(.)(.*)");
        Matcher matcher = pattern.matcher(line);
        if (matcher.find()) {
          String operator = matcher.group(1);
          String value = matcher.group(2);
          int number = Integer.parseInt(value);
          if (operator.matches("-")) {
            int newResult = result - number;
            result = newResult;
          } else {
            int newResult = result + number;
            result = newResult;
          }
        }
      }

      scanner.close();

      return result;
    } catch (Exception e) {
      System.out.println(e.getMessage());
      return 0;
    }
  }

  public static void main(String[] args) {
    System.out.println(new App().getSolution());
  }
}
